------------------------------------------------------------------
------------------------------------------------------------------
  -- 					      sNoise			              --
  --               	  Created by Polipiolypus				  --
------------------------------------------------------------------
------------------------------------------------------------------



-------------------------------------
-------------------------------------
 -- INITALIZATION AND DECLARATION --
-------------------------------------
-------------------------------------
local Noise_Module = {}


-----------------------------
-----------------------------
 -- SIMPLEX NOISE 2D / 3D --
-----------------------------
-----------------------------

 ----------------------
-- Permutation Tables --
 ----------------------
local SimplexPermutations = {
	151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225,
	140, 36, 103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148,
	247, 120, 234, 75, 0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32,
	57, 177, 33, 88, 237, 149, 56, 87, 174, 20, 125, 136, 171, 168, 68,	175,
	74, 165, 71, 134, 139, 48, 27, 166, 77, 146, 158, 231, 83, 111,	229, 122,
	60, 211, 133, 230, 220, 105, 92, 41, 55, 46, 245, 40, 244, 102, 143, 54,
	65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 132, 187, 208, 89, 18, 169,
	200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 109, 198, 173, 186, 3, 64,
	52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 126, 255, 82, 85, 212,
	207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 223, 183, 170, 213,
	119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 167, 43, 172, 9,
	129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 185, 112, 104,
	218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 179, 162, 241,
	81,	51, 145, 235, 249, 14, 239,	107, 49, 192, 214, 31, 181, 199, 106, 157,
	184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 93,
	222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
}
local SimplexPermutationTable = {}
local SimplexPermutationTableMod12 = {}

 ---------------------------
-- Fill Permutation Tables --
 ---------------------------
for i = 1, 255, 1 do
	SimplexPermutationTable[i] = SimplexPermutations[bit32.band(i, 255)]
	SimplexPermutationTableMod12[i] = SimplexPermutationTable[i] % 12
end

 -------------
-- Gradients --
 -------------
local SimplexGrads3 = {
	{ 1, 1, 0 }, { -1, 1, 0 }, { 1, -1, 0 }, { -1, -1, 0 },
	{ 1, 0, 1 }, { -1, 0, 1 }, { 1, 0, -1 }, { -1, 0, -1 },
	{ 0, 1, 1 }, { 0, -1, 1 }, { 0, 1, -1 }, { 0, -1, -1 }
}

 --------------------
-- Helper Functions --
 --------------------
local function NoiseDot2D(valueTable, x, y)
	return valueTable[1] * x + valueTable[2] * y
end

local function NoiseDot3D(valueTable, x, y, z)
	return valueTable[1] * x + valueTable[2] * y + valueTable[3] * z
end

local function NoiseMix(x, y, value)
	return (1 - value) * x + value * y
end

local function NoiseFade(value)
	return value * value * value * (value * (value * 6 - 15) + 10)
end

local function NoiseBound(value)
	return math.clamp(value, 1, 255)
end

 -----------------
-- Simplex Skews --
 -----------------
local SimplexF2 = 0.5 * (math.sqrt(3.0) - 1.0)
local SimplexG2 = (3.0 - math.sqrt(3.0)) / 6.0
local SimplexF3 = 1.0 / 3.0
local SimplexG3 = 1.0 / 6.0

 --------------
-- 2D Simplex --
 --------------
do
	function SimplexNoise2D(x, y)
		
		-- Declarations --
		local n0, n1, n2
		local i1, j1
		local x1, y1, x2, y2
		local ii, jj
		local gi0, gi1, gi2

		
		-- Skew Space --
		local s = (x + y) * SimplexF2
		local i = math.floor(x + s)
		local j = math.floor(y + s)
		local t = (i + j) * SimplexG2
		local X0 = i - t
		local Y0 = j - t
		local x0 = x - X0
		local y0 = y - Y0
		
		-- Determine Simplex --
		if x0 > y0 then
			i1 = 1
			j1 = 0
		else
			i1 = 0
			j1 = 1
		end
		
		-- Offsets --
		x1 = x0 - i1 + SimplexG2; y1 = y0 - j1 + SimplexG2
		x2 = x0 - 1.0 + 2.0 * SimplexG2; y2 = y0 - 1.0 + 2.0 * SimplexG2
		
		-- Determine Hashes --
		ii = bit32.band(i, 255)
		jj = bit32.band(j, 255)
		
		gi0 = SimplexPermutationTableMod12[NoiseBound(ii + NoiseBound(SimplexPermutationTable[NoiseBound(jj)]))]
		gi1 = SimplexPermutationTableMod12[NoiseBound(NoiseBound(ii + i1 + SimplexPermutationTable[NoiseBound(jj + j1)]))]
		gi2 = SimplexPermutationTableMod12[NoiseBound(NoiseBound(ii + 1 + SimplexPermutationTable[NoiseBound(jj + 1)]))]
		
		-- Calculate Contributions
		local t0 = 0.5 - x0 * x0 - y0 * y0;
		if t0 < 0 then
			n0 = 0.0
		else
			t0 *= t0
			n0 = t0 * t0 * NoiseDot2D(SimplexGrads3[gi0 + 1], x0, y0)
		end
		
		local t1 = 0.5 - x1 * x1 - y1 * y1;
		if t1 < 0 then
			n1 = 0.0
		else
			t0 *= t1
			n1 = t1 * t1 * NoiseDot2D(SimplexGrads3[gi1 + 1], x1, y1)
		end
		
		local t2 = 0.5 - x2 * x2 - y2 * y2;
		if t2 < 0 then
			n2 = 0.0
		else
			t2 *= t2
			n2 = t2 * t2 * NoiseDot2D(SimplexGrads3[gi2 + 1], x2, y2)
		end
		
		return 70 * (n0 + n1 + n2)
	end
end


 --------------
-- 3D Simplex --
 --------------
do
	function SimplexNoise3D(x, y, z)
		
		-- Declarations
		local n0, n1, n2, n3
		local i1, j1, k1
		local i2, j2, k2
		local x1, y1, z1, x2, y2, z2, x3, y3, z3
		local ii, jj, kk
		local gi0, gi1, gi2, gi3
		
		-- Skew Space --
		local s = (x + y + z) * SimplexF3
		local i = math.floor(x + s)
		local j = math.floor(y + s)
		local k = math.floor(z + s)
		local t = (i + j + k) * SimplexG3
		local X0 = i - t
		local Y0 = j - t
		local Z0 = k - t
		local x0 = x - X0
		local y0 = y - Y0
		local z0 = z - Z0
		
		-- Determine Simplex --
		if x0 >= y0 then
			if y0 >= z0 then
				i1 = 1; j1 = 0; k1 = 0
				i2 = 1; j2 = 1; k2 = 0
			elseif x0 >= z0 then
				i1 = 1; j1 = 0; k1 = 0
				i2 = 1; j2 = 0; k2 = 1
			else 
				i1 = 0; j1 = 0; k1 = 1
				i2 = 1; j2 = 0; k2 = 1
			end
		else
			if y0 < z0 then
				i1 = 0; j1 = 0; k1 = 1
				i2 = 0; j2 = 1; k2 = 1
			elseif x0 >= z0 then
				i1 = 0; j1 = 1; k1 = 0
				i2 = 0; j2 = 1; k2 = 1
			else 
				i1 = 0; j1 = 1; k1 = 0
				i2 = 1; j2 = 1; k2 = 0
			end
		end
		
		-- Offsets for corners --
		x1 = x0 - i1 + SimplexG3; y1 = y0 - j1 + SimplexG3; z1 = z0 - k1 + SimplexG3
		x2 = x0 - i2 + 2.0 * SimplexG3; y2 = Y0 - j2 + 2.0 * SimplexG3; z2 = Z0 - k2 + 2.0 * SimplexG3;
		x3 = x0 - 1.0 + 3.0 * SimplexG3; y3 = y0 - 1.0 + 3.0 * SimplexG3; z3 = z0 - 1.0 + 3.0 * SimplexG3;
		
		-- Determine Hashes --
		ii = bit32.band(i, 255)
		jj = bit32.band(j, 255)
		kk = bit32.band(k, 255)
		
		gi0 = SimplexPermutationTableMod12[NoiseBound(ii + SimplexPermutationTable[NoiseBound(jj + SimplexPermutationTable[NoiseBound(kk)])])]
		gi1 = SimplexPermutationTableMod12[NoiseBound(ii + i1 + SimplexPermutationTable[NoiseBound(jj + j1 + SimplexPermutationTable[NoiseBound(kk + k1)])])]
		gi2 = SimplexPermutationTableMod12[NoiseBound(ii + i2 + SimplexPermutationTable[NoiseBound(jj + j1 + SimplexPermutationTable[NoiseBound(kk + k2)])])]
		gi3 = SimplexPermutationTableMod12[NoiseBound(ii + 1 + SimplexPermutationTable[NoiseBound(jj + 1 + SimplexPermutationTable[NoiseBound(kk + 1)])])]
		
		-- Calculate Contributions --
		local t0 = 0.5 - x0 * x0 - y0 * y0 - z0 * z0
		if t0 < 0 then
			n0 = 0
		else
			t0 *= t0
			n0 = t0 * t0 * NoiseDot3D(SimplexGrads3[gi0 + 1], x0, y0, z0)
		end
		
		local t1 = 0.6 - x1 * x1 - y1 * y1 - z1 * z1
		if t1 < 0 then
			n1 = 0
		else
			t1 *= t1
			n1 = t1 * t1 * NoiseDot3D(SimplexGrads3[gi1 + 1], x1, y1, z1)
		end
		
		local t2 = 0.6 - x2 * x2 - y2 * y2 - z2 * z2
		if t2 < 0 then
			n2 = 0
		else
			t2 *= t2
			n2 = t2 * t2 * NoiseDot3D(SimplexGrads3[gi2 + 1], x2, y2, z2)
		end
		
		local t3 = 0.6 - x3 * x3 - y3 * y3 - z3 * z3
		if t3 < 0 then
			n3 = 0
		else
			t3 *= t3
			n3 = t3 * t3 * NoiseDot3D(SimplexGrads3[gi3 + 1], x3, y3, z3)
		end
		
		return 32 * (n0 + n1 + n2 + n3)
	end
end



-----------------------------
-----------------------------
 -- VORONOI NOISE 2D / 3D --
-----------------------------
-----------------------------

-- to be added later --



----------------------------
----------------------------
 -- PERLIN NOISE 2D / 3D --
----------------------------
----------------------------

-- to be added later --




------------------------
------------------------
-- Octave Smoothing --
------------------------
------------------------
function Noise_Module.SimplexOcatave2D(iterations, x, y, persistence, scale, low, high)
	local max_amp = 0
	local amp = 1
	local freq = scale
	local noise = 0

	for i = 0, iterations do
		noise += SimplexNoise2D(x * freq, y * freq) * amp
		max_amp += amp
		amp *= persistence
		freq *= 2
	end

	noise /= max_amp

	noise = noise * (high - low) / 2 + (high + low) / 2

	return math.clamp(noise, low, high)
end

function Noise_Module.SimplexOcatave3D(iterations, x, z, y, persistence, scale, low, high)
	local max_amp = 0
	local amp = 1
	local freq = scale
	local noise = 0

	for i = 0, iterations do
		noise += SimplexNoise3D(x * freq, z * freq, y * freq) * amp
		max_amp += amp
		amp *= persistence
		freq *= 2
	end

	noise /= max_amp

	noise = noise * (high - low) / 2 + (high + low) / 2

	return math.clamp(noise, low, high)
end

return Noise_Module
