using System;

namespace bh
{
	class Program
	{
		public static void Main(String[] args)
		{
			bool nextIsPort = false;

			for (var s in args)
			{
				if (nextIsPort)
				{
					GameApp.Port = int32.Parse(s);
					nextIsPort = false;
					continue;
				}
				if (s == "-p")
				{
					nextIsPort = true;
					continue;
				}
			}
			var app = scope GameApp();
			ari.RunApplication(app);
		}
	}
}
