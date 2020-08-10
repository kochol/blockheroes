using System;

namespace bh.game
{
	[Reflect]
	class Score
	{
		public int32[7] BlockCount;
		public int32[5] ClearedLines;
		public int32 ClearedLineCount;
		public int32 SendLineCount;
	}
}
