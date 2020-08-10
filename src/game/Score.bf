using System;
using System.Collections;

namespace bh.game
{
	[Reflect]
	class Score
	{
		public List<int32> BlockCount = new List<int32>(7) ~ delete _;
		public List<int32> ClearedLines = new List<int32>(4) ~ delete _;
		public int32 ClearedLineCount;
		public int32 SendLineCount;

		public this()
		{
			for (int i = 0; i < 7; i++)
				BlockCount.Add(0);
			for (int i = 0; i < 4; i++)
				ClearedLines.Add(0);
		}
	}
}
