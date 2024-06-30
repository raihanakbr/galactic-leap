using Godot;
using System;
using System.Security.Cryptography;
using System.Text;

public partial class GamePointSender : Node
{
	[Serializable]
	public class PointRequest
	{
		public string userPlaygroundId;
		public string attemptId;
		public int score;
	}


	[Serializable]
	public class PointResponse
	{
		public string statusCode;
		public string responseMessages;
		public string playgroundId;
		public string addedPoint;
		public string attemptId;

	}

	[Serializable]
	public class PointError
	{
		public string message;
		public string statusCode;
	}

	[Signal]
	public delegate void RequestFailedEventHandler(string errorMessage);
	[Signal]
	public delegate void SendPointSucceedEventHandler(string responseMessages, int addedPoint);
	[Signal]
	public delegate void SendPointFailedEventHandler(string errorMessage);

	private const string GAME_CODE = "ARCADE_1"; // TODO: Replace with your actual X-Gamecode, this one is for Momentum
	private const string SIGNATURE_SECRET = "oqtZiTK6y1S8IwmbBMWHtw=="; // TODO: Replace with your actual secret key, this one is for development
	private const string URL = "https://quantum-games-dev.fly.dev/point"; // TODO: Change based on environment (dev, production), this one is for development

	private HttpRequest _httpRequest;
	private GameCodeVerifier _gameCodeVerifier;

	public override void _Ready()
	{
		_gameCodeVerifier = GetNode<GameCodeVerifier>("/root/GlobalGameCodeVerifier"); // It's Autoload
		_httpRequest = new HttpRequest();
		AddChild(_httpRequest);
		_httpRequest.RequestCompleted += OnRequestCompleted;
	}

	public void SendPoint(int score)
	{
		DateTime now = DateTime.UtcNow;
		string timestamp = now.ToString("yyyy-MM-ddTHH:mm:ssZ");

		// var requestDict = new Godot.Collections.Dictionary
		// {
		// 	{ "userPlaygroundId", _gameCodeVerifier.UserPlaygroundId },
		// 	{ "attemptId", _gameCodeVerifier.AttemptId },
		// 	{ "score", score },
		// };

		// string requestBody = Json.Stringify(requestDict);

		string requestBody = $"{{\"userPlaygroundId\":\"{_gameCodeVerifier.UserPlaygroundId}\",\"attemptId\":\"{_gameCodeVerifier.AttemptId}\",\"score\":{score}}}";
		byte[] bodyRaw = Encoding.UTF8.GetBytes(requestBody);

		string signature = GenerateSignature(bodyRaw, timestamp);

		var headers = new string[]
		{
			"Content-Type: application/json",
			"X-Gamecode: " + GAME_CODE,
			"X-Timestamp: " + timestamp,
			"X-Signature: " + signature
		};

		// GD.Print(headers);
		// GD.Print(requestBody);

		Error err = _httpRequest.Request(URL, headers, HttpClient.Method.Post, requestBody);
		if (err != Error.Ok)
		{
			EmitSignal(SignalName.RequestFailed, err.ToString());
		}
	}

	private void OnRequestCompleted(long result, long responseCode, string[] headers, byte[] body)
	{
		string resultBody = Encoding.UTF8.GetString(body);

		// GD.Print("Result Body: ", resultBody);
	
		if (responseCode == 200)
		{
			var response = Json.ParseString(resultBody).AsGodotDictionary();

			_gameCodeVerifier.UserPlaygroundId = "";
			_gameCodeVerifier.AttemptId = "";

			EmitSignal(SignalName.SendPointSucceed, response["responseMessages"], response["addedPoint"]);
		}
		else
		{
			var error = Json.ParseString(resultBody).AsGodotDictionary();
			
			EmitSignal(SignalName.SendPointFailed, error["message"].ToString());
		}
	}

	public static string GenerateSignature(byte[] body, string timestamp)
	{
		byte[] hashBody = SHA256.Create().ComputeHash(body);
		string hexHash = BitConverter.ToString(hashBody).Replace("-", "").ToLower();

		string signatureBase = $"{"POST"}:{"/point"}:{hexHash}:{timestamp}";

		using (var hmac = new HMACSHA512(Encoding.UTF8.GetBytes(SIGNATURE_SECRET)))
		{
			byte[] signatureBytes = hmac.ComputeHash(Encoding.UTF8.GetBytes(signatureBase));
			return Convert.ToBase64String(signatureBytes);
		}

	}
}
