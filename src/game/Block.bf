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
		const float BlockSizeHalf = BlockSize / 2.0f;

		Sprite2D[] sprites = new Sprite2D[4];
		static TextureHandle block_texture = .();

		// Block position
		Vector2 position;

		this(EntityHandle _handle) : base(_handle)
		{
			if (block_texture.Handle == uint32.MaxValue)
			{
				block_texture = Gfx.LoadTexture("res:block.png");
			}
		}

		public ~this()
		{
			delete blocks;
			for (int i = 0; i < 4; i++)
				delete sprites[i];
			delete sprites;
		}

		void UpdateBlockPos()
		{
			switch(block_type)
			{
			case .Box:
				blocks[0].x = blocks[2].x = 0.0f;			//	[2][3]
				blocks[1].x = blocks[3].x = 1.0f;			//	[0][1]
				blocks[0].y = blocks[1].y = 0.0f;
				blocks[2].y = blocks[3].y = 1.0f;
			case .Z:
				if (direction == .North || direction == .South)
				{
					blocks[0].x = -1.0f;					//	[0][1]
					blocks[1].x = blocks[2].x = 0.0f;		//	   [2][3]
					blocks[3].x = 1.0f;
					blocks[0].y = blocks[1].y = 1.0f;
					blocks[2].y = blocks[3].y = 0.0f;
				}
				else
				{
					blocks[0].x = blocks[1].x = 0;			//	   [0]
					blocks[2].x = blocks[3].x = -1;			//	[2][1]
					blocks[1].y = blocks[2].y = 0.0f;		//  [3]
					blocks[3].y = -1;
				}
			case .RZ:
				if (direction == .North || direction == .South)
				{
					blocks[0].x = -1.0f;					//	   [2][3]	
					blocks[1].x = blocks[2].x = 0.0f;		//	[0][1]
					blocks[3].x = 1.0f;
					blocks[0].y = blocks[1].y = 0.0f;
					blocks[2].y = blocks[3].y = 1.0f;
				}
				else
				{
					blocks[3].x = blocks[2].x = 0;			//	   [3]
					blocks[1].x = blocks[0].x = 1;			//	   [2][1]
					blocks[1].y = blocks[2].y = 0.0f;		//  	  [0]
					blocks[0].y = -1;
				}
			case .T:
				switch (direction)
				{
				case .North:
					blocks[0].x = -1.0f;					//	[0][1][2]
					blocks[1].x = blocks[3].x = 0.0f;		//	   [3]
					blocks[2].x = 1.0f;
					blocks[0].y = blocks[1].y = blocks[2].y = 0;
					blocks[3].y = -1;
				case .East:
					blocks[0].x = blocks[1].x = blocks[2].x =  0;					
					blocks[3].x = -1;						//	   [0]
					blocks[0].y = 1;						//	[3][1]
					blocks[1].y = blocks[3].y = 0;			//     [2]
					blocks[2].y = -1;
				case .South:
					blocks[0].x = -1.0f;					//	   [3]
					blocks[1].x = blocks[3].x = 0.0f;		//	[0][1][2]
					blocks[2].x = 1.0f;
					blocks[0].y = blocks[1].y = blocks[2].y = 0;
					blocks[3].y = 1;
				case .West:
					blocks[0].x = blocks[1].x = blocks[2].x =  0;					
					blocks[3].x = 1;						//	   [0]
					blocks[0].y = 1;						//     [1][3]
					blocks[1].y = blocks[3].y = 0;			//     [2]
					blocks[2].y = -1;
				}
			case .L:
				switch (direction)
				{
				case .North:
					blocks[0].x = blocks[1].x = blocks[2].x = 0.0f;
					blocks[3].x = 1.0f;						//	[0]
					blocks[0].y = 1;						//	[1]
					blocks[1].y = 0;						//	[2][3]
					blocks[2].y = blocks[3].y = -1;
				case .East:
					blocks[2].x = blocks[3].x = -1;			//	[2][1][0]
					blocks[1].x = 0;						//	[3]
					blocks[0].x = 1;
					blocks[0].y = blocks[1].y = blocks[2].y = 0;
					blocks[3].y = -1;
				case .South:
					blocks[0].x = blocks[1].x = blocks[2].x = 0.0f;
					blocks[3].x = -1;						//	[3][0]
					blocks[2].y = -1;						//	   [1]
					blocks[1].y = 0;						//	   [2]
					blocks[0].y = blocks[3].y = 1;
				case .West:
					blocks[0].x = blocks[3].x = 1;			//	      [3]
					blocks[1].x = 0;						//	[2][1][0]
					blocks[2].x = -1;
					blocks[0].y = blocks[1].y = blocks[2].y = 0;
					blocks[3].y = 1;
				}
			case .RL:
				switch (direction)
				{
				case .North:
					blocks[0].x = blocks[1].x = blocks[2].x = 0.0f;
					blocks[3].x = -1.0f;					//	   [0]
					blocks[0].y = 1.0f;						//	   [1]
					blocks[1].y = 0.0f;						// 	[3][2]
					blocks[2].y = blocks[3].y = -1.0f;
				case .East:
					blocks[0].x = 1;						//	[3]
					blocks[1].x = 0;						//	[2][1][0]
					blocks[2].x = blocks[3].x = -1;
					blocks[0].y = blocks[1].y = blocks[2].y = 0;
					blocks[3].y = 1;
				case .South:
					blocks[0].x = blocks[1].x = blocks[2].x = 0.0f;
					blocks[3].x = 1;						//	   [0][3]
					blocks[2].y = -1;						//	   [1]
					blocks[1].y = 0;						//	   [2]
					blocks[0].y = blocks[3].y = 1;
				case .West:
					blocks[2].x = -1;						//	[2][1][0]
					blocks[1].x = 0;						//		  [3]
					blocks[0].x = blocks[3].x = 1;
					blocks[0].y = blocks[1].y = blocks[2].y = 0;
					blocks[3].y = -1;
				}
			case .I:
				if (direction == .North || direction == .South)
				{
					blocks[0].y = blocks[1].y = blocks[2].y = blocks[3].y = 0.0f;
					blocks[0].x = -1.0f;					//	[0][1][2][3]
					blocks[1].x = 0.0f;
					blocks[2].x = 1.0f;
					blocks[3].x = 2.0f;
				}
				else
				{
					blocks[0].x = blocks[1].x = blocks[2].x = 0.0f;
					blocks[3].x = 0;						//	   [0]
					blocks[0].y = 2.0f;						//	   [1]
					blocks[1].y = 1.0f;						// 	   [2]
					blocks[2].y = 0.0f;						//	   [3]
					blocks[3].y = -1;
				}
			case .BlockLine:
				// TODO: add block line type
				System.Runtime.NotImplemented();
			}

			// Set the sprite pos
			for (int i = 0; i < 4; i++)
				*sprites[i].Position = (blocks[i] + position) * BlockSize + BlockSizeHalf;
		}

		// Create components, Add them to world
		public void Init(World _world, BlockType _block_type, Vector2 _pos)
		{
			block_type = _block_type;
			position = _pos;

			// Create components
			for (int i = 0; i < 4; i++)
			{
				sprites[i] = World.CreateSprite2D();
				sprites[i].Scale.x = sprites[i].Scale.y = BlockSize;
				*sprites[i].Texture = block_texture;
				_world.AddComponent(this, sprites[i]);
			}

			UpdateBlockPos();

			// Add entity to world
			_world.AddEntity(this);
		}

		public void HandleInput(KeyType _key)
		{
			switch (_key)
			{
			case .RotateCW:
				switch (direction)
				{
				case .North: direction = .East;
				case .East: direction = .South;
				case .South: direction = .West;
				case .West: direction = .North;
				}
			case .RotateCCW:
				switch (direction)
				{
				case .North: direction = .West;
				case .East: direction = .North;
				case .South: direction = .East;
				case .West: direction = .South;
				}
			case .Down: position.y = 18.0f;
			case .Left: position.x -= 1.0f;
			case .Right: position.x += 1.0f;
			default:
			}

			UpdateBlockPos();
		}
	}
}
