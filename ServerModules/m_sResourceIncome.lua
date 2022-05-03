local m_sResourceIncome = {
	-- Holds a table of all the cost of every resource type and tier --
	["Copper"] = {
		[1] = {speed = 4.00, money = 1 },
		[2] = {speed = 3.50, money = 2 },
		[3] = {speed = 3.00, money = 3 },
		[4] = {speed = 2.50, money = 4 },
		[5] = {speed = 2.00, money = 5 }
	},
	["Tin"] = {
		[1] = {speed = 4.00, money = 2 },
		[2] = {speed = 3.50, money = 4 },
		[3] = {speed = 3.00, money = 6 },
		[4] = {speed = 2.50, money = 8 },
		[5] = {speed = 2.00, money = 10 }
	},
	["Coal"] = {
		[1] = {speed = 4.00, money = 4 },
		[2] = {speed = 3.50, money = 8 },
		[3] = {speed = 3.00, money = 12 },
		[4] = {speed = 2.50, money = 16 },
		[5] = {speed = 2.00, money = 20 }
	},
	["Aluminum"] = {
		[1] = {speed = 4.00, money = 8 },
		[2] = {speed = 3.50, money = 16 },
		[3] = {speed = 3.00, money = 24 },
		[4] = {speed = 2.50, money = 36 },
		[5] = {speed = 2.00, money = 40 }
	},
	["Lead"] = {
		[1] = {speed = 4.00, money = 16 },
		[2] = {speed = 3.50, money = 32 },
		[3] = {speed = 3.00, money = 48 },
		[4] = {speed = 2.50, money = 64 },
		[5] = {speed = 2.00, money = 80 }
	},
	["Iron"] = {
		[1] = {speed = 4.00, money = 32 },
		[2] = {speed = 3.50, money = 64 },
		[3] = {speed = 3.00, money = 96 },
		[4] = {speed = 2.50, money = 128 },
		[5] = {speed = 2.00, money = 160 }
	}, 
	["Silver"] = {
		[1] = {speed = 4.00, money = 64 },
		[2] = {speed = 3.50, money = 128 },
		[3] = {speed = 3.00, money = 192 },
		[4] = {speed = 2.50, money = 256 },
		[5] = {speed = 2.00, money = 320 }
	},
	["Tungsten"] = {
		[1] = {speed = 4.00, money = 128 },
		[2] = {speed = 3.50, money = 256 },
		[3] = {speed = 3.00, money = 384 },
		[4] = {speed = 2.50, money = 512 },
		[5] = {speed = 2.00, money = 640 }
	},
	["Gold"] = {
		[1] = {speed = 4.00, money = 256 },
		[2] = {speed = 3.50, money = 512 },
		[3] = {speed = 3.00, money = 768 },
		[4] = {speed = 2.50, money = 1024 },
		[5] = {speed = 2.00, money = 1280 }
	},
	["Platinum"] = {
		[1] = {speed = 4.00, money = 512 },
		[2] = {speed = 3.50, money = 1024 },
		[3] = {speed = 3.00, money = 1536 },
		[4] = {speed = 2.50, money = 2048 },
		[5] = {speed = 2.00, money = 2560 }
	}
}
return m_sResourceIncome
