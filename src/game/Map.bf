using ari;
using System.Collections;

namespace bh.game
{
	public class Map
	{
		bool[,] data = new bool[10,20] ~ delete _;
		World world = null;
		List<Block> blocks = new List<Block>() ~ DeleteContainerAndItems!(_);

		enum GameState
		{
			NeedNewBlock,
			BlockIsDropping
		}

		GameState state = .NeedNewBlock;

		public void Init(World _world)
		{
			world = _world;
		}

		public void Update(float _elasped_time)
		{
			if (state == .NeedNewBlock)
			{
				Block b = World.CreateEntity<Block>();
				b.Init(world, .Box);
				blocks.Add(b);
				state = .BlockIsDropping;
			}
		}
	}
}
