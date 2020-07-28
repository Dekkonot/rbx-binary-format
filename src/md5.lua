local T = { [0] =
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
    0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
    0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
    0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
    0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391,
}

local SHIFT_ORDER = {[0] =
    07, 12, 17, 22, 07, 12, 17, 22, 07, 12, 17, 22, 07, 12, 17, 22,
    05, 09, 14, 20, 05, 09, 14, 20, 05, 09, 14, 20, 05, 09, 14, 20,
    04, 11, 16, 23, 04, 11, 16, 23, 04, 11, 16, 23, 04, 11, 16, 23,
    06, 10, 15, 21, 06, 10, 15, 21, 06, 10, 15, 21, 06, 10, 15, 21,
}

local APPEND_CHAR = string.char(0x80)
local INT_32_CAP = 2^32

---Packs four 8-bit integers into one 32-bit little endian integer
local function packUint32LittleEndian(a, b, c, d)
    return bit32.lshift(d, 24)+bit32.lshift(c, 16)+bit32.lshift(b, 8)+a
end

---Unpacks one 32-bit little endian integer into four 8-bit integers
local function unpackUint32LittleEndian(int)
    return bit32.extract(int, 00, 8), bit32.extract(int, 08, 8),
           bit32.extract(int, 16, 8), bit32.extract(int, 24, 8)
end

local function F(x, y, z)
    return bit32.bor(bit32.band(x, y), bit32.band(bit32.bnot(x), z))
end

local function G(x, y, z)
    return bit32.bor(bit32.band(x, z), bit32.band(y, bit32.bnot(z)))
end

local function H(x, y, z)
    return bit32.bxor(x, y, z)
end

local function I(x, y, z)
    return bit32.bxor(y, bit32.bor(x, bit32.bnot(z)))
end

local function preprocessMessage(message)
    local initMsgLen = #message*8 -- Message length in bits
    local msgLen = initMsgLen+8
    local nulCount = 0
    message = message..APPEND_CHAR
    while (msgLen+64)%512 ~= 0 do
        nulCount = nulCount+1
        msgLen = msgLen+8
    end
    message = message..string.rep("\0", nulCount)
    message = message..string.char(unpackUint32LittleEndian(initMsgLen))
    message = message..string.rep("\0", 4) -- Regrettably can't append 64-bits of length to the message since Lua uses doubles
    return message
end

---Hashes `message` using the MD5 algorithm
local function md5(message)
    message = preprocessMessage(message)

    local A = 0x67452301
    local B = 0xefcdab89
    local C = 0x98badcfe
    local D = 0x10325476

    local X = {}

    for i = 1, #message, 64 do
        local place = i
        for j = 0, 15 do
            X[j] = packUint32LittleEndian(string.byte(message, place, place+3))
            place = place+4
        end

        local a, b, c, d = A, B, C, D

        local temp, aux, k

        for j = 0, 63 do
            if j <= 15 then
                aux = F(b, c, d)
                k = j
            elseif j <= 31 then
                aux = G(b, c, d)
                k = (5*j+1)%16
            elseif j <= 47 then
                aux = H(b, c, d)
                k = (3*j+5)%16
            else
                aux = I(b, c, d)
                k = (7*j)%16
            end

            temp = d
            d = c
            c = b
            b = b + bit32.lrotate(a + aux + T[j] + X[k], SHIFT_ORDER[j])
            a = temp
        end

        A = (A+a)%INT_32_CAP
        B = (B+b)%INT_32_CAP
        C = (C+c)%INT_32_CAP
        D = (D+d)%INT_32_CAP
    end

    local b0, b1, b2, b3 = unpackUint32LittleEndian(A)
    local b4, b5, b6, b7 = unpackUint32LittleEndian(B)
    local b8, b9, b10, b11 = unpackUint32LittleEndian(C)
    local b12, b13, b14, b15 = unpackUint32LittleEndian(D)

    return string.format("%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c", b0, b1, b2, b3, b4, b5, b6, b7, b8, b9, b10, b11, b12, b13, b14, b15)
end

return md5