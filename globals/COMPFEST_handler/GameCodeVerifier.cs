using Godot;
using System;
using System.Text;
using System.Security.Cryptography;
using System.Threading.Tasks;

public partial class GameCodeVerifier : Node
{
	[Serializable]
	public class GameCodeRequest
	{
		public string uniqueCode;
	}

	[Serializable]
	public class GameCodeResponse
	{
		public string statusCode;
		public string responseMessages;
		public UserResponse user;
		public string attemptId;
	}

	[Serializable]
	public class UserResponse
	{
		public string userPlaygroundId;
		public string username;
	}


	[Serializable]
	public class GameCodeError
	{
		public string message;
		public string statusCode;
	}

	[Signal]
	public delegate void RequestFailedEventHandler(string errorMessage);
	[Signal]
	public delegate void GameCodeSucceedEventHandler(string responseMessages);
	[Signal]
	public delegate void GameCodeFailedEventHandler(string errorMessage);

	private const string GAME_CODE = "ARCADE_1"; // TODO: Replace with your actual X-Gamecode, this one is for Momentum
	private const string SIGNATURE_SECRET = "oqtZiTK6y1S8IwmbBMWHtw=="; // TODO: Replace with your actual secret key, this one is for development
	private const string URL = "https://quantum-games-dev.fly.dev/auth"; // TODO: Change based on environment (dev, production), this one is for development

	public string UserPlaygroundId { get; set; }
	public string AttemptId { get; set; }

	private HttpRequest _httpRequest;

	public override void _Ready()
	{
		_httpRequest = new HttpRequest();
		AddChild(_httpRequest);
		_httpRequest.RequestCompleted += OnRequestCompleted;
	}

	public void VerifyGameCode(string code)
	{
		DateTime now = DateTime.UtcNow;
		string timestamp = now.ToString("yyyy-MM-ddTHH:mm:ssZ");

		var requestDict = new Godot.Collections.Dictionary
		{
			{ "uniqueCode", code }
		};

		string requestBody = Json.Stringify(requestDict);
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
			var responseJson = Json.ParseString(resultBody).AsGodotDictionary();

			UserPlaygroundId = responseJson["user"].AsGodotDictionary()["userPlaygroundId"].ToString();
			AttemptId = responseJson["attemptId"].ToString();

			EmitSignal(SignalName.GameCodeSucceed, responseJson["responseMessages"].ToString());
		}
		else
		{
			var errorJson = Json.ParseString(resultBody).AsGodotDictionary();

			EmitSignal(SignalName.GameCodeFailed, errorJson["message"].ToString());
		}
	}

	public static string GenerateSignature(byte[] body, string timestamp)
	{
		byte[] hashBody = SHA256.Create().ComputeHash(body);
		string hexHash = BitConverter.ToString(hashBody).Replace("-", "").ToLower();

		string signatureBase = $"{"POST"}:{"/auth"}:{hexHash}:{timestamp}";

		using (var hmac = new HMACSHA512(Encoding.UTF8.GetBytes(SIGNATURE_SECRET)))
		{
			byte[] signatureBytes = hmac.ComputeHash(Encoding.UTF8.GetBytes(signatureBase));
			return Convert.ToBase64String(signatureBytes);
		}

	}
}
