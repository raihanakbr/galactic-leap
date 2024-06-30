class_name SHA512

const K := [
	"428a2f98d728ae22", "7137449123ef65cd", "b5c0fbcfec4d3b2f", "e9b5dba58189dbbc",
	"3956c25bf348b538", "59f111f1b605d019", "923f82a4af194f9b", "ab1c5ed5da6d8118",
	"d807aa98a3030242", "12835b0145706fbe", "243185be4ee4b28c", "550c7dc3d5ffb4e2",
	"72be5d74f27b896f", "80deb1fe3b1696b1", "9bdc06a725c71235", "c19bf174cf692694",
	"e49b69c19ef14ad2", "efbe4786384f25e3", "0fc19dc68b8cd5b5", "240ca1cc77ac9c65",
	"2de92c6f592b0275", "4a7484aa6ea6e483", "5cb0a9dcbd41fbd4", "76f988da831153b5",
	"983e5152ee66dfab", "a831c66d2db43210", "b00327c898fb213f", "bf597fc7beef0ee4",
	"c6e00bf33da88fc2", "d5a79147930aa725", "06ca6351e003826f", "142929670a0e6e70",
	"27b70a8546d22ffc", "2e1b21385c26c926", "4d2c6dfc5ac42aed", "53380d139d95b3df",
	"650a73548baf63de", "766a0abb3c77b2a8", "81c2c92e47edaee6", "92722c851482353b",
	"a2bfe8a14cf10364", "a81a664bbc423001", "c24b8b70d0f89791", "c76c51a30654be30",
	"d192e819d6ef5218", "d69906245565a910", "f40e35855771202a", "106aa07032bbd1b8",
	"19a4c116b8d2d0c8", "1e376c085141ab53", "2748774cdf8eeb99", "34b0bcb5e19b48a8",
	"391c0cb3c5c95a63", "4ed8aa4ae3418acb", "5b9cca4f7763e373", "682e6ff3d6b2b8a3",
	"748f82ee5defb2fc", "78a5636f43172f60", "84c87814a1f0ab72", "8cc702081a6439ec",
	"90befffa23631e28", "a4506cebde82bde9", "bef9a3f7b2c67915", "c67178f2e372532b",
	"ca273eceea26619c", "d186b8c721c0c207", "eada7dd6cde0eb1e", "f57d4f7fee6ed178",
	"06f067aa72176fba", "0a637dc5a2c898a6", "113f9804bef90dae", "1b710b35131c471b",
	"28db77f523047d84", "32caab7b40c72493", "3c9ebe0a15c9bebc", "431d67c49c100d4c",
	"4cc5d4becb3e42b6", "597f299cfc657e2a", "5fcb6fab3ad6faec", "6c44198c4a475817"
]

static func add_hex(a: String, b: String) -> String:
	var result = ""
	var carry = 0
	for i in range(15, -1, -1):
		var digit_a = "0123456789abcdef".find(a[i])
		var digit_b = "0123456789abcdef".find(b[i])
		var sum = digit_a + digit_b + carry
		result = "0123456789abcdef"[sum % 16] + result
		carry = sum / 16
	return result

static func hex_to_bin(hex_string: String) -> String:
	var bin_string = ""
	for c in hex_string:
		var bin = ""
		var n = "0123456789abcdef".find(c.to_lower())
		for i in range(4):
			bin = str(n & 1) + bin
			n >>= 1
		bin_string += bin
	return bin_string

static func bin_to_hex(bin_string: String) -> String:
	var hex_string = ""
	for i in range(0, bin_string.length(), 4):
		var nibble = bin_string.substr(i, 4)
		var n = 0
		for j in range(4):
			n = (n << 1) | int(nibble[j])
		hex_string += "0123456789abcdef"[n]
	return hex_string

static func rotr(n: String, b: int) -> String:
	var bin = hex_to_bin(n)
	var rotated = bin.substr(bin.length() - b) + bin.substr(0, bin.length() - b)
	return bin_to_hex(rotated)

static func shr(n: String, b: int) -> String:
	var bin = hex_to_bin(n)
	var shifted = "0".repeat(b) + bin.substr(0, bin.length() - b)
	return bin_to_hex(shifted)

static func xor_hex(a: String, b: String) -> String:
	var result = ""
	for i in range(16):
		var digit_a = "0123456789abcdef".find(a[i])
		var digit_b = "0123456789abcdef".find(b[i])
		result += "0123456789abcdef"[digit_a ^ digit_b]
	return result

static func and_hex(a: String, b: String) -> String:
	var result = ""
	for i in range(16):
		var digit_a = "0123456789abcdef".find(a[i])
		var digit_b = "0123456789abcdef".find(b[i])
		result += "0123456789abcdef"[digit_a & digit_b]
	return result

static func not_hex(a: String) -> String:
	var result = ""
	for i in range(16):
		var digit = "0123456789abcdef".find(a[i])
		result += "0123456789abcdef"[15 - digit]
	return result

static func ch(x: String, y: String, z: String) -> String:
	return xor_hex(and_hex(x, y), and_hex(not_hex(x), z))

static func maj(x: String, y: String, z: String) -> String:
	return xor_hex(xor_hex(and_hex(x, y), and_hex(x, z)), and_hex(y, z))

static func sigma0(x: String) -> String:
	return xor_hex(xor_hex(rotr(x, 28), rotr(x, 34)), rotr(x, 39))

static func sigma1(x: String) -> String:
	return xor_hex(xor_hex(rotr(x, 14), rotr(x, 18)), rotr(x, 41))

static func gamma0(x: String) -> String:
	return xor_hex(xor_hex(rotr(x, 1), rotr(x, 8)), shr(x, 7))

static func gamma1(x: String) -> String:
	return xor_hex(xor_hex(rotr(x, 19), rotr(x, 61)), shr(x, 6))

static func sha512(message: PackedByteArray) -> PackedByteArray:
	var h := [
		"6a09e667f3bcc908", "bb67ae8584caa73b",
		"3c6ef372fe94f82b", "a54ff53a5f1d36f1",
		"510e527fade682d1", "9b05688c2b3e6c1f",
		"1f83d9abfb41bd6b", "5be0cd19137e2179"
	]
	var message_len := message.size()
	message.append(0x80)
	while (message.size() + 8) % 128 != 0:
		message.append(0)
	
	var bit_len := message_len * 8
	for i in range(8):
		message.append((bit_len >> (56 - i * 8)) & 0xFF)
	
	printt("message", message)
	
	for chunk_start in range(0, message.size(), 128):
		var w := []
		for t in range(16):
			var start = chunk_start + t * 8
			var end = start + 8
			var chunk = message.slice(start, end)
			w.append(bytes_to_hex(chunk))
		
		printt("w", w)
		
		for t in range(16, 80):
			var temp = add_hex(add_hex(add_hex(gamma1(w[t-2]), w[t-7]), gamma0(w[t-15])), w[t-16])
			w.append(temp)
		
		var a = h[0]
		var b = h[1]
		var c = h[2]
		var d = h[3]
		var e = h[4]
		var f = h[5]
		var g = h[6]
		var hh = h[7]
		
		for t in range(80):
			var t1 = add_hex(add_hex(add_hex(add_hex(hh, sigma1(e)), ch(e, f, g)), K[t]), w[t])
			var t2 = add_hex(sigma0(a), maj(a, b, c))
			hh = g
			g = f
			f = e
			e = add_hex(d, t1)
			d = c
			c = b
			b = a
			a = add_hex(t1, t2)
		
		h[0] = add_hex(h[0], a)
		h[1] = add_hex(h[1], b)
		h[2] = add_hex(h[2], c)
		h[3] = add_hex(h[3], d)
		h[4] = add_hex(h[4], e)
		h[5] = add_hex(h[5], f)
		h[6] = add_hex(h[6], g)
		h[7] = add_hex(h[7], hh)
	
	var result := PackedByteArray()
	for value in h:
		result.append_array(hex_to_bytes(value))
	
	return result

static func hex_to_bytes(hex_string: String) -> PackedByteArray:
	var bytes = PackedByteArray()
	for i in range(0, hex_string.length(), 2):
		var byte = "0123456789abcdef".find(hex_string[i]) * 16 + "0123456789abcdef".find(hex_string[i+1])
		bytes.append(byte)
	return bytes

static func bytes_to_hex(bytes: PackedByteArray) -> String:
	var hex_string = ""
	for byte in bytes:
		hex_string += "0123456789abcdef"[byte >> 4]
		hex_string += "0123456789abcdef"[byte & 0xF]
	return hex_string
