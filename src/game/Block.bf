using ari;

namespace bh.game
{
	public enum BlockType
	{
		Box,
		Z,
		RZ,
		T,
		L,
		RL,
		I,
		BlockLine
	}

	public enum Direction
	{
	    North,
	    East,
	    South,
	    West
	}

	public class Block : Entity
	{
		Vector2[] blocks = new Vector2[4];
		BlockType block_type;
		Direction direction = .North;
		const float BlockSize = 32.0f;
		Sprite2D[] sprites = new Sprite2D[4];

		this(EntityHandle _handle) : base(_handle)
		{

		}

		public ~this()
		{
			delete blocks;
		}

		// Create components, Add them to world
		public void Init(World _world, BlockType _block_type)
		{
			block_type = _block_type;
			switch(_block_type)
			{
			case .Box:
				blocks[0].x = blocks[2].x = 0.0f;		//	[2][3]
				blocks[1].x = blocks[3].x = 1.0f;		//	[0][1]
				blocks[0].y = blocks[1].y = 0.0f;
				blocks[2].y = blocks[3].y = 1.0f;
			case .Z:
				blocks[0].x = -1.0f;					//	[0][1]
				blocks[1].x = blocks[2].x = 0.0f;		//	   [2][3]
				blocks[3].x = 1.0f;
				blocks[0].y = blocks[1].y = 1.0f;
				blocks[2].y = blocks[3].y = 0.0f;
			case .RZ:
				blocks[0].x = -1.0f;					//	   [2][3]	
				blocks[1].x = blocks[2].x = 0.0f;		//	[0][1]
				blocks[3].x = 1.0f;
				blocks[0].y = blocks[1].y = 0.0f;
				blocks[2].y = blocks[3].y = 1.0f;
			case .T:
				blocks[0].x = -1.0f;					//	[0][1][2]
				blocks[1].x = blocks[3].x = 0.0f;		//	   [3]
				blocks[2].x = 1.0f;
				blocks[0].y = blocks[1].y = blocks[2].y = 1.0f;
				blocks[3].y = 0.0f;
			case .L:
				blocks[0].x = blocks[1].x = blocks[2].x = 0.0f;
				blocks[3].x = 1.0f;						//	[0]
				blocks[0].y = 2.0f;						//	[1]
				blocks[1].y = 1.0f;						//	[2][3]
				blocks[2].y = blocks[3].y = 0.0f;
			case .RL:
				blocks[0].x = blocks[1].x = blocks[2].x = 0.0f;
				blocks[3].x = -1.0f;					//	   [0]
				blocks[0].y = 2.0f;						//	   [1]
				blocks[1].y = 1.0f;						// 	[3][2]
				blocks[2].y = blocks[3].y = 0.0f;
			case .I:
				blocks[0].x = blocks[1].x = blocks[2].x = blocks[3].x = 0.0f;
				blocks[0].y = 3.0f;						//	[0]
				blocks[1].y = 2.0f;						// 	[1]
				blocks[2].y = 1.0f;						//	[2]
				blocks[3].y = 0.0f;						//	[3]
			case .BlockLine:
				// TODO: add block line type
			}

			// Create components
			for (int i = 0; i < 4; i++)
			{
				sprites[i] = World.CreateSprite2D();
				sprites[i].Scale.x = sprites[i].Scale.y = BlockSize;
				_world.AddComponent(this, sprites[i]);
			}

			// Add entity to world
			_world.AddEntity(this);
		}
	}
}
