using ari.gui;
using imgui_beef;
using System;
using ari.user;

namespace bh.gui
{
	class GameHistory: ScriptGui
	{
		public bool IsOpen = true;
		bool CallEnd;
		GameList games = null ~ delete _;
		bool gameListCalled = false;
		bool isFailed = false;

		protected override bool BeginRender()
		{
			CallEnd = IsOpen;
			if (IsOpen && ImGui.Begin("GameHistory", &IsOpen))
			{
				if (games == null)
				{
					if (!isFailed)
						ImGui.Text("Loading...");
					else
					{
						ImGui.Text("Failed to load");
						if (ImGui.Button("retry"))
						{
							gameListCalled = false;
							isFailed = false;
						}
					}

					if (!gameListCalled)
					{
						gameListCalled = true;
						GameApp.profile_system.GetGames(0, 20, new (_games) => {
							delete games;
							games = _games;
						}, new (err) => {
							isFailed = true;
						});
					}
				}
				else
				{
					// show the game list
					ImGui.Columns(4);

					ImGui.Text("Opponent"); ImGui.NextColumn();
					ImGui.Text("Status"); ImGui.NextColumn();
					ImGui.Text("Score"); ImGui.NextColumn();
					ImGui.Text("Replay"); ImGui.NextColumn();
					ImGui.Separator();

					if (games.Games.Count > 0)
					{
						String tmp = scope String();
						int32 player_team_id;
						for (var g in games.Games)
						{
							// Opponent
							tmp.Clear();
							if (g.teams[0][0].playerId != GameApp.Player.id)
							{
								g.teams[0][0].playerId.ToString(tmp);
								player_team_id = 1;
							}
							else
							{
								g.teams[1][0].playerId.ToString(tmp);
								player_team_id = 0;
							}
							ImGui.Text(tmp); ImGui.NextColumn();

							// Win or lose
							if (player_team_id == g.winnerTeamId)
							{
								ImGui.TextColored(.(0, 1, 0, 1), "Win");
							}
							else
							{
								ImGui.TextColored(.(1, 0, 0, 1), "Lose");
							}
							ImGui.NextColumn();

							// score
							ImGui.TextWrapped(g.teams[player_team_id][0].score); ImGui.NextColumn();

							// Download replay
							tmp.Clear();
							tmp.AppendF("Replay{}", g.id);
							ImGui.PushID(tmp);
							if (ImGui.Button("Play Replay"))
							{
								Console.WriteLine(g.id);
							}
							ImGui.PopID();
							ImGui.NextColumn();
						}
					}

					ImGui.Columns();
					if (games.Games.Count == 0)
					{
						ImGui.Text("Nothing to show. Play some multiplayer game");
					}
					ImGui.Separator();
				}
				return true;
			}
			return false;
		}

		protected override void EndRender()
		{
			if (CallEnd)
				ImGui.End();
		}

	}
}
