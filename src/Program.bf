using System;

namespace bh
{
	class Program
	{
		public static void Main(String[] args)
		{
			bool nextIsPort = false;
			bool nextIsIp = false;
			bool nextIsToken = false;
			bool nextIsLobbyId = false;

			for (var s in args)
			{
				if (nextIsPort)
				{
					GameApp.Port = int32.Parse(s);
					nextIsPort = false;
					continue;
				}
				if (nextIsIp)
				{
					GameApp.IP = s;
					nextIsIp = false;
					continue;
				}
				if (nextIsToken)
				{
					GameApp.Token = s;
					nextIsToken = false;
					continue;
				}
				if (nextIsLobbyId)
				{
					GameApp.LobbyId = int64.Parse(s);
					nextIsLobbyId = false;
					continue;
				}
				if (s == "-p")
				{
					nextIsPort = true;
					continue;
				}
				if (s == "-i")
				{
					nextIsIp = true;
					continue;
				}
				if (s == "-t")
				{
					nextIsToken = true;
					continue;
				}
				if (s == "-l")
				{
					nextIsLobbyId = true;
					continue;
				}
			}
			var app = scope GameApp();
			ari.RunApplication(app);
		}
	}
}
