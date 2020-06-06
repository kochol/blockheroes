using ari;
using System;
using System.Collections;
using bh.game;

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
		RPC m_rpc_on_opponent_connect;
		RPC m_rpc_on_opponent_connect_client;
		RPC m_rpc_start_game;
		RPC m_rpc_on_input_server;
		RPC m_rpc_on_input;
		RPC m_rpc_on_add_block_type;
		RPC m_rpc_on_punishment;
		RPC m_rpc_on_apply_punishment;
		RPC m_rpc_on_apply_punishment_server;
		int32 my_client_id = -1;

		int m_num_created_blocks = 0;
		List<BlockType> blocks = new List<BlockType>(50) ~ delete _;
		Random rnd = new Random() ~ delete _;

		bool game_started = false;
		World world;

		// time values
		float time = 0;
		float key_time = 0;
		KeyType last_key = .Drop;
		const float UpdateTime = 0.5f;
		const float KeyUpdateDelay = 0.1f;

		// log file
#if !BF_PLATFORM_ANDROID
		System.IO.StreamWriter loger = new System.IO.StreamWriter() ~ delete _;
#endif
		int32 counter = 0;

		void OnConnect(int32 client_id)
		{
			var str = scope String();
			client_id.ToString(str);
			str.Append("log.txt");
#if !BF_PLATFORM_ANDROID
			loger.Create(str);
#endif			
			Console.WriteLine("Connected to server: {0}", client_id);
			my_client_id = client_id;
		}

		void OnApplyPunishment(int32 _client_id)
		{
#if !BF_PLATFORM_ANDROID
			loger.WriteLine("OnApplyPunishment {}", _client_id);
#endif
			if (my_client_id != _client_id)
				clients[_client_id].ApplyPunishment();
		}

		void OnPunishment(int32 _client_id, int8 _block_hole)
		{
#if !BF_PLATFORM_ANDROID
			loger.WriteLine("OnPunishment {} {}", _client_id, _block_hole);
#endif
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

		void OnOpponentConnect(int32 client_id)
		{
			var map = new Map();
			map.Init(world, client_id, my_client_id == client_id, blocks);
			map.send_punishment_from = new => OnPunishmentFrom;
			map.apply_punishment = new => OnPunishmentApplied;
			clients.Add(client_id, map);
			if (my_client_id == client_id)
				return;
			Console.WriteLine("Opponent Connected to server: {0}", client_id);
		}

		void StartGame()
		{
			game_started = true;
		}

#if ARI_SERVER
		ServerSystem network = null;

		void OnClientConnected(int32 client_id)
		{
			network.CallRPC(client_id, m_rpc_on_connect, client_id);
			network.CallRPC(m_rpc_on_opponent_connect, client_id);
			// send the blocks
			for (int i = 0; i < 50; i++)
				network.CallRPC(client_id, m_rpc_on_add_block_type, blocks[i]);

			for (var i in clients)
			{
				if (i.key == client_id)
					continue;
				network.CallRPC(client_id, m_rpc_on_opponent_connect_client, i.key);
			}
			if (clients.Count > 1)
				// start the game
				network.CallRPC(m_rpc_start_game);
		}

		void OnClientDisconnected(int32 client_id)
		{
			delete clients[client_id];
			clients.Remove(client_id);

			if (clients.Count == 0)
			{
				// Create new blocks for the next game
				blocks.Clear();
				for (int i = 0; i < 50; i++)
					blocks.Add((BlockType)rnd.Next(7));
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
			loger.Create("log_server.txt");
			network.OnClientConnected = new => this.OnClientConnected;
			network.OnClientDisconnected = new => this.OnClientDisconnected;
			for (int i = 0; i < 50; i++)
				blocks.Add((BlockType)rnd.Next(7));
#endif

			// set RPCs
			m_rpc_on_connect = Net.AddRPC<int32>("OnConnect", .Client, new => OnConnect, true);
			m_rpc_on_opponent_connect = Net.AddRPC<int32>("OnOpponentConnect", .MultiCast, new => OnOpponentConnect, true);
			m_rpc_on_opponent_connect_client = Net.AddRPC<int32>("OnOpponentConnectClient", .Client, new => OnOpponentConnect, true);
			m_rpc_start_game = Net.AddRPC("StartGame", .MultiCast, new => StartGame, true);
			m_rpc_on_input_server = Net.AddRPC<KeyType>("HandleInputServer", .Server, new => HandleInputServer, true);
			m_rpc_on_input = Net.AddRPC<int32, KeyType, int32>("HandleInput", .MultiCast, new => HandleInput, true);
			m_rpc_on_add_block_type = Net.AddRPC<BlockType>("AddBlockType", .Client, new => AddBlockType, true);
			m_rpc_on_punishment = Net.AddRPC<int32, int8>("OnPunishment", .MultiCast, new => OnPunishment, true);
			m_rpc_on_apply_punishment = Net.AddRPC<int32>("OnApplyPunishment", .MultiCast, new => OnApplyPunishment, true);
			m_rpc_on_apply_punishment_server = Net.AddRPC("OnApplyPunishmentServer", .Server, new => OnApplyPunishmentServer, true);
		}

		// Server calls this to update the inputs
		void HandleInput(int32 client_id, KeyType _key, int32 c)
		{
#if !BF_PLATFORM_ANDROID
			loger.WriteLine("HandleInput: {} {} {}", client_id, _key, c);
#endif
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
			if (!game_started)
				return;

			if (key_time < KeyUpdateDelay && last_key == _key)
				return;
			key_time = 0;
			if (_key == .Down)
				time = 0;
			last_key = _key;

			network.CallRPC(m_rpc_on_input_server, _key);
			clients[my_client_id].HandleInput(_key);
		}

		public void AddBlockType(BlockType _type)
		{
			blocks.Add(_type);
		}

		public void Update(float _elasped_time)
		{
			bool update_time = true;
			for (var c in clients)
			{
				if (c.key == my_client_id &&
					(c.value.[Friend]state == .NeedNewBlock || c.value.[Friend]state == .GameOver))
				{
					time = 0;
					update_time = false;
				}
				c.value.Update(_elasped_time);
			}

			if (!update_time || !game_started)
				return;

			time += _elasped_time;
			key_time += _elasped_time;
			if (time < UpdateTime)
				return;
			time = 0;

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
					network.CallRPC(c.key, m_rpc_on_add_block_type, bt);
				}
			}
#endif

			if (my_client_id > -1)
			{
				network.CallRPC<KeyType>(m_rpc_on_input_server, .Down);
				clients[my_client_id].HandleInput(.Down);
			}
		}
	}
}
