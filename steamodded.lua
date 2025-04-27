BUMod.current_mod = SMODS.current_mod

SMODS.Atlas({
	key = "modicon",
	path = "icon.png",
	px = 48,
	py = 48,
})

BUMod.current_mod.credits_tab = function()
	return {
		n = G.UIT.ROOT,
		config = {
			align = "cm",
			padding = 0.05,
			colour = G.C.CLEAR,
		},
		nodes = {
			{
				n = G.UIT.R,
				config = {
					padding = 0,
					align = "cm",
				},
				nodes = {
					{
						n = G.UIT.O,
						config = {
							object = DynaText({
								string = "Madi's Language Mod",
								colours = { G.C.MONEY },
								shadow = true,
								scale = 0.8,
								float = true,
								spacing = 5,
							}),
						},
					},
				},
			},
			{
				n = G.UIT.R,
				config = { minh = 0.15 },
			},
			{
				n = G.UIT.R,
				config = {
					padding = 0,
					align = "cm",
				},
				nodes = {
					{
						n = G.UIT.T,
						config = {
							text = "Special for Madi",
							shadow = true,
							scale = 0.45,
							colour = G.C.UI.TEXT_LIGHT,
						},
					},
				},
			},
			{
				n = G.UIT.R,
				config = { minh = 0.25 },
			},
			{
				n = G.UIT.R,
				config = { align = "cm" },
				nodes = {
					{
						n = G.UIT.R,
						nodes = {
							{
								n = G.UIT.R,
								config = {
									padding = 0.2,
									colour = G.C.BLACK,
									r = 0.05,
									minw = 6.65,
									align = "m",
								},
								nodes = {
									{
										n = G.UIT.R,
										config = {
											align = "cm",
										},
										nodes = {
											{
												n = G.UIT.T,
												config = {
													text = "Code contributors",
													scale = 0.45,
													colour = G.C.UI.TEXT_LIGHT,
													align = "cm",
												},
											},
										},
									},
									{
										n = G.UIT.R,
										config = {
											align = "cm",
										},
										nodes = {
											{
												n = G.UIT.C,
												config = { align = "cm" },
												nodes = {
													{
														n = G.UIT.R,
														config = { padding = 0.025 },
														nodes = {
															{
																n = G.UIT.T,
																config = {
																	text = "Created by ",
																	scale = 0.3,
																	colour = G.C.UI.TEXT_LIGHT,
																	align = "cm",
																},
															},
															{
																n = G.UIT.T,
																config = {
																	text = "Madi",
																	scale = 0.3,
																	colour = G.C.ORANGE,
																	align = "cm",
																},
															},
														},
													},
													{
														n = G.UIT.R,
														config = { padding = 0.025 },
														nodes = {
															{
																n = G.UIT.T,
																config = {
																	text = "Maintained by ",
																	scale = 0.3,
																	colour = G.C.UI.TEXT_LIGHT,
																	align = "cm",
																},
															},
															{
																n = G.UIT.T,
																config = {
																	text = "Madi",
																	scale = 0.3,
																	colour = G.C.ORANGE,
																	align = "cm",
																},
															},
														},
													},
												},
											},
										},
									},
								},
							},
						},
					},
					{
						n = G.UIT.R,
						config = { minh = 0.15 },
					},
				},
			},
		},
	}
end
