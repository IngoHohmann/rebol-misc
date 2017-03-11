Rebol [
	file: %hmac.reb
	author: "Graham Chiu"
	date: 11-Mar-2017
	notes: {
		calculates the hmac-sha256 of a message given a key
		As of this date, the function passes all 6 test vectors from https://tools.ietf.org/html/rfc4868#page-7

		blocksize should be 512 but for whatever reason works when set to 64
	}
]

comment { from wikipedia
function hmac (key, message) {
    if (length(key) > blocksize) {
        key = hash(key) // keys longer than blocksize are shortened
    }
    if (length(key) < blocksize) {
        // keys shorter than blocksize are zero-padded (where ∥ is concatenation)
        key = key ∥ [0x00 * (blocksize - length(key))] // Where * is repetition.
    }
   
    o_key_pad = [0x5c * blocksize] ⊕ key // Where blocksize is that of the underlying hash function
    i_key_pad = [0x36 * blocksize] ⊕ key // Where ⊕ is exclusive or (XOR)
   
    return hash(o_key_pad ∥ hash(i_key_pad ∥ message)) // Where ∥ is concatenation
}
}

hmac-sha256: function [k m][
	key: copy k
	message: copy m
	blocksize: 64
	if (length key) > blocksize [
		key: sha256 key
	]
	if (length key) < blocksize [
		insert/dup tail key #{00} (blocksize - length key)
	]
	insert/dup opad: copy #{} #{5C} blocksize
	insert/dup ipad: copy #{} #{36} blocksize
	o_key_pad: XOR~ opad key
	i_key_pad: XOR~ ipad key
	sha256 join-of o_key_pad sha256 join-of i_key_pad message
]

test-vectors: [
	#{0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b} #{4869205468657265}  #{b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7}
	
	#{4a656665} #{7768617420646f2079612077616e7420666f72206e6f7468696e673f} #{5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843}
	
	#{aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa} #{dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd}
	#{773ea91e36800e46854db8ebd09181a72959098b3ef8c122d9635514ced565fe}
	
	#{0102030405060708090a0b0c0d0e0f10111213141516171819} #{cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd}
	#{82558a389a443c0ea4cc819899f2083a85f0faa3e578f8077a2e3ff46729665b}

	#{aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa} 
	#{54657374205573696e67204c6172676572205468616e20426c6f636b2d53697a65204b6579202d2048617368204b6579204669727374} 
	#{60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54}

	#{aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa}
	#{5468697320697320612074657374207573696e672061206c6172676572207468616e20626c6f636b2d73697a65206b657920616e642061206c6172676572207468616e20626c6f636b2d73697a6520646174612e20546865206b6579206e6565647320746f20626520686173686564206265666f7265206265696e6720757365642062792074686520484d414320616c676f726974686d2e}
	#{9b09ffa71b942fcb27635fbcd5b0e944bfdc63644f0713938a7f51535c3a35e2}	
]

cnt: 0
for-each [key data expected] test-vectors [
	++ cnt
	result: hmac-sha256 key data
	print [ "Test number " cnt equal? expected hmac-sha256 key data]
]
