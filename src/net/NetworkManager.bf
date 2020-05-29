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
		RPC m_rpc_on_input;
		int32 my_client_id = -1;

		void OnConnect(int32 client_id)
		{
			Console.WriteLine("Connected to server: {0}", client_id);
			my_client_id = client_id;
		}

		void OnOpponentConnect(int32 client_id)
		{
			clients.Add(client_id, new Map());
			if (my_client_id == client_id)
				return;
			Console.WriteLine("Opponent Connected to server: {0}", client_id);
		}

		void StartGame()
		{

		}

#if ARI_SERVER
		ServerSystem network = null;

		void OnClientConnected(int32 client_id)
		{
			network.CallRPC(client_id, m_rpc_on_connect, client_id);
			network.CallRPC(m_rpc_on_opponent_connect, client_id);
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
		}

		public this(ServerSystem _network)
#else
		ClientSystem network = null;

		public this(ClientSystem _network)
#endif
		{
			network = _network;
#if ARI_SERVER
			network.OnClientConnected = new => this.OnClientConnected;
			network.OnClientDisconnected = new => this.OnClientDisconnected;
#endif

			// set RPCs
			m_rpc_on_connect = Net.AddRPC<int32>("OnConnect", .Client, new => OnConnect, true);
			m_rpc_on_opponent_connect = Net.AddRPC<int32>("OnOpponentConnect", .MultiCast, new => OnOpponentConnect, true);
			m_rpc_on_opponent_connect_client = Net.AddRPC<int32>("OnOpponentConnectClient", .Client, new => OnOpponentConnect, true);
			m_rpc_start_game = Net.AddRPC("StartGame", .MultiCast, new => StartGame, true);
		}
	}
}
