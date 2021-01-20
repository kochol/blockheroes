using ari;
using System;
using System.Collections;
using bh.game;
using System.IO;
using ari.user;
using JSON_Beef.Serialization;
using ari.net;
using ari.en;

namespace bh.net
{
	public class NetworkManager
	{
		Dictionary<int32, Map> clients = new Dictionary<int32, Map>(2) ~
		{
			for (var value in _)
			{
				delete value.value;
			}
			delete _;
		};
		RPC m_rpc_on_connect;
		RPC m_rpc_on_player_id_server;
		RPC m_rpc_on_opponent_connect;
		RPC m_rpc_on_opponent_connect_client;
		RPC m_rpc_start_game;
		RPC m_rpc_on_input_server;
		RPC m_rpc_on_input;
		RPC m_rpc_on_add_block_type;
		RPC m_rpc_on_punishment;
		RPC m_rpc_on_apply_punishment;
		RPC m_rpc_on_apply_punishment_server;
		RPC m_rpc_on_apply_new_line_server;
		RPC m_rpc_on_apply_new_line_multicast;
		int32 my_client_id = -1;

		int m_num_created_blocks = 0;
		List<BlockType> blocks = new List<BlockType>(50) ~ delete _;
		Random rnd = new Random() ~ delete _;

		public bool game_started = false;
		public bool GamePaused = false;
		public bool ReplayMode = false;
		bool single_player = false;
		World world;

		bool is_in_game = false;
		uint64 game_start_time;

		Lobby lobby = null ~ delete _;

		// time values
		float time = 0;
		int time_reduced_times = 0;
		float key_time = 0;
		KeyType last_key = .Drop;
		const float UpdateTime = 0.5f;
		const float KeyUpdateDelay = 0.05f;
		float GameTime = 0;

		int32 counter = 0;

		void OnConnect(int32 client_id)
		{
			if (ReplayMode)
				return;

			Console.WriteLine("Connected to server: {0}", client_id);
			my_client_id = client_id;
			is_in_game = true;
			game_start_time = Timer.Now();
			network.CallRPC(m_rpc_on_player_id_server, client_id, GameApp.Player == null ? 0 : GameApp.Player.id);
		}

		void OnPlayerIdServer(int32 client_id, int64 player_id)
		{
			network.CallRPC(m_rpc_on_opponent_connect, client_id, player_id);
			// send the blocks
			for (int i = 0; i < blocks.Count; i++)
				network.CallRPC(client_id, m_rpc_on_add_block_type, blocks[i], client_id);

			for (var i in clients)
			{
				if (i.key == client_id)
					continue;
				network.CallRPC(client_id, m_rpc_on_opponent_connect_client, i.key, i.value.PlayerId);
			}
			if (clients.Count > 1)
			{
				// start the game
				network.CallRPC(m_rpc_start_game);
				// tell the server game started
				GameApp.profile_system.ServerStartGame(GameApp.LobbyId);
			}
		}

		void OnApplyPunishment(int32 _client_id)
		{
			if (my_client_id != _client_id)
				clients[_client_id].ApplyPunishment();
		}

		void OnPunishment(int32 _client_id, int8 _block_hole)
		{
			clients[_client_id].AddPunishment(_block_hole);
		}

		// Client call the server that he applied the punishment
		void OnApplyPunishmentServer()
		{
			var client_id = Net.GetLastRpcClientIndex();
			network.CallRPC(m_rpc_on_apply_punishment, client_id);
		}

		// Client calls this event when they apply one punishment
		void OnPunishmentApplied()
		{
			// send the event to server
			network.CallRPC(m_rpc_on_apply_punishment_server);
		}

		// Server calls this event when they cleared multi lines and wants to punish others
		void OnPunishmentFrom(int32 _client_id)
		{
			// Send the punishment to opponents
			for (var c in clients)
			{
				if (c.key != _client_id)
				{
					network.CallRPC(m_rpc_on_punishment, c.key, int8(rnd.Next(10)));
				}
			}
		}

		void OnApplyNewLineMultiCast(int32 _client_id)
		{
			if (_client_id == my_client_id)
				return;

			clients[_client_id].ApplyNewLine();
		}

		// Client calls this to tell the server he applied new block
		void OnApplyNewLineServer()
		{
			var client_id = Net.GetLastRpcClientIndex();
			network.CallRPC(m_rpc_on_apply_new_line_multicast, client_id);
		}

		// Client calls this event when they make a new line.
		void OnApplyNewLine()
		{
			network.CallRPC(m_rpc_on_apply_new_line_server);
		}

		void OnOpponentConnect(int32 client_id, int64 playerId)
		{
			if (clients.ContainsKey(client_id))
				return;

			var map = new Map();
			map.Init(world, client_id, my_client_id == client_id, blocks);
			map.PlayerId = playerId;
			if (ReplayMode && client_id == 0)
				map.[Friend]canvas.Rect.x = 0;
			map.send_punishment_from = new => OnPunishmentFrom;
			map.apply_punishment = new => OnPunishmentApplied;
			map.apply_new_line = new => OnApplyNewLine;
			clients.Add(client_id, map);
			if (my_client_id == client_id)
				return;
			Console.WriteLine("Opponent Connected to server: {0}", client_id);
		}

		void StartGame()
		{
			game_started = true;
#if !ARI_SERVER
			if (ReplayMode)
				network.SetFastForward(false);
#endif
		}

#if ARI_SERVER
		ServerSystem network = null;

		void OnClientConnected(int32 client_id)
		{
			network.CallRPC(client_id, m_rpc_on_connect, client_id);
		}

		void OnClientDisconnected(int32 client_id)
		{
			if (lost_client_id < 0)
				lost_client_id = client_id;

			ExitServer();

			if (clients.ContainsKey(client_id))
			{
				delete clients[client_id];
				clients.Remove(client_id);
			}
		}

		bool is_exit_server_called = false;
		int32 lost_client_id = -1;

		void ExitServer()
		{
			if (is_exit_server_called)
				return;
			is_exit_server_called = true;

			// Send the game result to profile server
			if (game_started && clients.Count > 1 && lobby != null)
			{
				Console.WriteLine("Save the game");
				Game game = scope Game();
				game.winnerTeamId = lost_client_id == 0 ? 1 : 0;
				game.teams = new List<List<PlayerScore>>();
				game.version = new String(GameApp.NetworkVersion);
				game.gameDuration = GameTime;
				// Add players scores
				for (var kv in clients)
				{
					var r = JSONSerializer.Serialize<String>(kv.value.PlayerScore);
					game.teams.Add(new List<PlayerScore>());
					int i = game.teams.Count - 1;
					game.teams[i].Add(new PlayerScore(kv.value.PlayerId, r.Value));
				}
				GameApp.profile_system.ServerSaveGame(game, new (res) => {
					// Now save the replay to server
					if (res.StatusCode == 200)
					{
						let game_id = int64.Parse(res.Body);

						// Save the replay to the file
						if (network.GetReplaySize() > 0)
						{
							// Compress the replay
							int32 size = network.GetReplaySize();
							let c = ari.io.Zip.Compress(network.GetReplay(), ref size);

							// Upload it to server
							GameApp.profile_system.ServerUploadReplay(game_id, c, size, new (res) => {
								ari.core.Memory.Free(c);
								res.Dispose();
								Application.Exit = true;
							});
						}
					}
					else
					{
						Logger.Error("Error when saving game to server");
						Application.Exit = true;
					}
					res.Dispose();
				});
			}
			else
			{
				Application.Exit = true;
			}
		}

		public this(ServerSystem _network, World _world)
#else
		ClientSystem network = null;

		public this(ClientSystem _network, World _world)
#endif
		{
			network = _network;
			world = _world;
#if ARI_SERVER
			network.RecordReplay();
			network.OnClientConnected = new => this.OnClientConnected;
			network.OnClientDisconnected = new => this.OnClientDisconnected;
			for (int i = 0; i < 50; i++)
				blocks.Add((BlockType)rnd.Next(7));

			// Get Lobby Data from server
			if (GameApp.LobbyId > 0)
				GameApp.profile_system.ServerGetLobby(GameApp.LobbyId, new (_lobby) => {
					lobby = _lobby;
				});
#endif

			// set RPCs
			m_rpc_on_connect = Net.AddRPC<int32>("OnConnect", .Client, new => OnConnect, true);
			m_rpc_on_player_id_server = Net.AddRPC<int32, int64>("OnPlayerIdServer", .Server, new => OnPlayerIdServer, true);
			m_rpc_on_opponent_connect = Net.AddRPC<int32, int64>("OnOpponentConnect", .MultiCast, new => OnOpponentConnect, true);
			m_rpc_on_opponent_connect_client = Net.AddRPC<int32, int64>("OnOpponentConnectClient", .Client, new => OnOpponentConnect, true);
			m_rpc_start_game = Net.AddRPC("StartGame", .MultiCast, new => StartGame, true);
			m_rpc_on_input_server = Net.AddRPC<KeyType>("HandleInputServer", .Server, new => HandleInputServer, true);
			m_rpc_on_input = Net.AddRPC<int32, KeyType, int32>("HandleInput", .MultiCast, new => HandleInput, true);
			m_rpc_on_add_block_type = Net.AddRPC<BlockType, int32>("AddBlockType", .Client, new => AddBlockType, true);
			m_rpc_on_punishment = Net.AddRPC<int32, int8>("OnPunishment", .MultiCast, new => OnPunishment, true);
			m_rpc_on_apply_punishment = Net.AddRPC<int32>("OnApplyPunishment", .MultiCast, new => OnApplyPunishment, true);
			m_rpc_on_apply_punishment_server = Net.AddRPC("OnApplyPunishmentServer", .Server, new => OnApplyPunishmentServer, true);
			m_rpc_on_apply_new_line_server = Net.AddRPC("OnApplyNewLineServer", .Server, new => OnApplyNewLineServer, true);
			m_rpc_on_apply_new_line_multicast = Net.AddRPC<int32>("OnApplyNewLineMultiCast", .MultiCast, new => OnApplyNewLineMultiCast, true);
		}

		public ~this()
		{
			GameEnded();
		}

		void GameEnded()
		{
			if (is_in_game && GameApp.Analytics != null)
			{
				int32 time = (int32)Timer.ToMilliSeconds(Timer.Since(game_start_time));
				if (single_player)
					GameApp.Analytics.Timing("Play", "Single player", time);
				else
					GameApp.Analytics.Timing("Play", "Multi player", time);
			}
			is_in_game = false;
			blocks.Clear();
		}

		// Server calls this to update the inputs
		void HandleInput(int32 client_id, KeyType _key, int32 c)
		{
			if (!game_started || client_id == my_client_id)
				return;

			clients[client_id].HandleInput(_key);
		}

		// client send the input to server and server multi cast it to every one
		public void HandleInputServer(KeyType _key)
		{
			if (!game_started)
				return;
			var client_id = Net.GetLastRpcClientIndex();
			network.CallRPC(m_rpc_on_input, client_id, _key, counter++);
		}

		// Handle input on client
		public void HandleInput(KeyType _key)
		{
			if (!game_started || ReplayMode)
				return;

			if (key_time < KeyUpdateDelay && last_key == _key)
				return;
			key_time = 0;
			if (_key == .Down) // comment this line for: Don't go down while player move the block
			{
				time = 0;
				time_reduced_times = 0;
			}
			else if (time_reduced_times < 7)
			{
				time *= 0.5f;
				time_reduced_times++;
			}
			last_key = _key;

			network.CallRPC(m_rpc_on_input_server, _key);
			clients[my_client_id].HandleInput(_key);
		}

		public void AddBlockType(BlockType _type, int32 client_id)
		{
			if (!ReplayMode || (ReplayMode && client_id == 0))
				blocks.Add(_type);
		}

		public void Update(float _elasped_time)
		{
			if (single_player && GamePaused)
				return;

			GameTime += _elasped_time;

			if (!game_started)
			{
#if ARI_SERVER
				if (GameTime > 30) // Exit the server if the game does not started after 30 seconds
				{
					ExitServer();
				}
#endif // ARI_SERVER
				return;
			}

			bool update_time = true;
			for (var c in clients)
			{
				if (c.key == my_client_id &&
					(c.value.[Friend]state == .NeedNewBlock || c.value.[Friend]state == .GameOver))
				{
					time = 0;
					time_reduced_times = 0;
					update_time = false;
				}
				c.value.Update(_elasped_time);

				// check for game over on server
#if ARI_SERVER
				if (c.value.[Friend]state == .GameOver) 
				{
					if (lost_client_id < 0)
						lost_client_id = c.key;

					ExitServer();

					return;
				}
#endif // ARI_SERVER

			}

			if (!update_time)
				return;

			time += _elasped_time;
			key_time += _elasped_time;
			if (time < UpdateTime)
				return;
			time = 0;
			time_reduced_times = 0;

#if ARI_SERVER
			// check that we need to add new block
			int blocks_used = 0;
			for (var c in clients)
			{
				blocks_used = Math.Max(blocks_used, c.value.last_block);
			}
			if (blocks.Count - blocks_used < 10)
			{
				BlockType bt = (BlockType)rnd.Next(7);
				blocks.Add(bt);
				for (var c in clients)
				{
					network.CallRPC(c.key, m_rpc_on_add_block_type, bt, c.key);
				}
			}
#endif

			if (single_player && blocks.Count - clients[0].last_block < 10)
				blocks.Add((BlockType)rnd.Next(7));

			if (my_client_id > -1)
			{
				network.CallRPC<KeyType>(m_rpc_on_input_server, .Down);
				clients[my_client_id].HandleInput(.Down);
			}
		} // Update

		public void StartSinglePlayer()
		{
			single_player = true;
			Gfx.SetWindowSize(GameApp.CanvasWidth, 640, true);
			OnConnect(0);
			OnOpponentConnect(0, GameApp.Player == null ? 0 : GameApp.Player.id);
			StartGame();
			blocks.Clear();
			for (int i = 0; i < 50; i++)
				blocks.Add((BlockType)rnd.Next(7));
		}

		public void ResetGame()
		{
			Runtime.Assert(single_player);
			delete clients[0];
			clients.Remove(0);
			GameEnded();
			StartSinglePlayer();
			GamePaused = false;
		}

		public void Exit()
		{
			for (var value in clients)
			{
				delete value.value;
			}
			clients.Clear();
			network.Stop();
			GameEnded();
			single_player = false;
			my_client_id = -1;
			game_started = false;
			GamePaused = false;
			ReplayMode = false;
			Gfx.SetWindowSize(GameApp.CanvasWidth * 2, 640, true);
		}

		public int GetCurrentBlockId()
		{
			if (my_client_id >= 0)
			{
				if (clients.Count > my_client_id)
				{
					return clients[my_client_id].last_block;
				}
			}
			return -1;
		}
	}
}
