using ari;
using System.Collections;
using System;

namespace bh.game
{
	public class Map
	{
		Sprite2D[,] data = new Sprite2D[10,20] ~ delete _;
		World world = null;
		Entity map_entity;
		Canvas canvas;
		Camera2D camera;
		Sprite2D left_wall;
		Sprite2D right_wall;
		Block active_block = null;
		WindowHandle window_handle;
		List<BlockType> blocks;
		public int last_block = 0;
		public int last_block_cleared = 0;
		public int cleard_block_combo = 0;
		int32 client_id;
		List<int8> punishments = new List<int8>() ~ delete _;
		bool is_player = false;

		// events
		public delegate void SendPunishmentFrom(int32 _client_id);
		public SendPunishmentFrom send_punishment_from = null ~ delete _;
		public delegate void ApplyPunishmentDelegate();
		public ApplyPunishmentDelegate apply_punishment = null ~ delete _;

		enum GameState
		{
			NeedNewBlock,
			BlockIsDropping,
			GameOver
		}

		GameState state = .NeedNewBlock;

		public ~this()
		{
			delete map_entity;
			delete camera;
			delete active_block;
			delete canvas;
			delete left_wall;
			delete right_wall;
			for (int i = 0; i < 10; i++)
			{
				for (int j = 0; j < 20; j++)
				{
					delete data[i, j];
				}
			}
		}

		public void Init(World _world, int32 _client_id, bool _is_player, List<BlockType> _blocks)
		{
			client_id = _client_id;
			blocks = _blocks;
			is_player = _is_player;
			window_handle.Handle = 0;
			window_handle.Index = 0;
			for (int i = 0; i < 10; i++)
			{
				for (int j = 0; j < 20; j++)
				{
					data[i, j] = null;
				}
			}
			world = _world;
			camera = World.CreateCamera2D();
			canvas = World.CreateCanvas();
			canvas.Rect.width = 330;
			canvas.Rect.height = 640;
			canvas.Rect.y = 0;
			if (_is_player)
				canvas.Rect.x = 0;
			else
				canvas.Rect.x = 330;
			canvas.AddChild(camera);

			// add walls
			Block.LoadTexture();
			left_wall = World.CreateSprite2D();
			//*left_wall.Texture = Block.[Friend]block_texture;
			left_wall.Scale.x = 5;
			left_wall.Scale.y = 640;
			left_wall.Position.x = 2.5f;
			left_wall.Position.y = 320;
			right_wall = World.CreateSprite2D();
			//*right_wall.Texture = Block.[Friend]block_texture;
			right_wall.Scale.x = 5;
			right_wall.Scale.y = 640;
			right_wall.Position.x = 327.5f;
			right_wall.Position.y = 320;
			canvas.AddChild(left_wall);
			canvas.AddChild(right_wall);

			map_entity = World.CreateEntity();
			world.AddComponent(map_entity, canvas);
			world.AddComponent(map_entity, camera);
			world.AddComponent(map_entity, left_wall);
			world.AddComponent(map_entity, right_wall);
			world.AddEntity(map_entity);
		}

		public bool Collide(Vector2[4] block_pos, Vector2 _pos)
		{
			for (int i = 0; i < 4; i++)
			{
				Vector2 p = block_pos[i] + _pos;
				int x = int(p.x);
				int y = int(p.y);
				if (x < 0 || x > 9 ||
					y < 0 || y > 19 ||
					data[x, y] != null)
					return true;
			}

			return false;
		}

		public void Update(float _elasped_time)
		{
			if (state == .NeedNewBlock)
			{
				if (active_block != null)
					delete active_block;

				if (blocks.Count <= last_block)
					return;

				BlockType bt = blocks[last_block];
				last_block++;
				active_block = World.CreateEntity<Block>();
				active_block.Init(world, bt, Vector2(5, 18), this);
				canvas.AddChild(active_block);
				state = .BlockIsDropping;
				return;
			}
		}

		public void HandleInput(KeyType _key)
		{
			if (state != .BlockIsDropping)
				return;

			active_block.HandleInput(_key);
		}

		void MoveBlocks(int y, bool down)
		{
			float dy = -Block.[Friend]BlockSize;

			for (int j = y; j < 20; j++)
			{
				for (int i = 0; i < 10; i++)
				{
					if (data[i, j] != null)
					{
						data[i, j].Position.y += dy;
						data[i, j - 1] = data[i, j];
						data[i, j] = null;
					}
				}
			}
		}

		public void AddPunishment(int8 _hole)
		{
			punishments.Add(_hole);
		}

		void ApplyPunishment(int8 _hole)
		{
			for (int y = 18; y >= 0; y--)
			{
				for (int x = 0; x < 10; x++)
				{
					if (data[x, y + 1] != null)
					{
						state = .GameOver;
						return;
					}
					if (data[x, y] != null)
						data[x, y].Position.y += Block.BlockSize;
					data[x, y + 1] = data[x, y];
					data[x, y] = null;
				}
			}
			for (int i = 0; i < 10; i++)
			{
				if (i == _hole)
					continue;

				data[i, 0] = Block.CreateBlockSprite();
				//*data[i, 0].Color = Color.BROWN;
				data[i, 0].Position.Set(i * Block.BlockSize + Block.BlockSizeHalf + Block.BlockOffsetx, Block.BlockSizeHalf);
				canvas.AddChild(data[i, 0]);
				world.AddComponent(map_entity, data[i, 0]);
			}
		}

		public void ApplyPunishment()
		{
			if (is_player)
			{
				for (var h in punishments)
				{
					apply_punishment();
					ApplyPunishment(h);
				}
				punishments.Clear();
			}
			else
			{
				var h = punishments[0];
				punishments.RemoveAt(0);
				ApplyPunishment(h);
			}
		}

		public void BlockReachedToEnd()
		{
			if (last_block_cleared < last_block - 1)
			{
				cleard_block_combo = 0; // reset the combo
			}

			for (int i = 0; i < 4; i++)
			{
				Vector2 p = active_block.[Friend]blocks[i] + active_block.[Friend]position;
				int x = int(p.x);
				int y = int(p.y);
				if (y >= 19 || data[x, y] != null)
				{
					state = .GameOver;
					return;
				}
				data[x, y] = active_block.[Friend]sprites[i];
				world.RemoveComponent(active_block, active_block.[Friend]sprites[i], false);
				canvas.AddChild(data[x, y]);
				world.AddComponent(map_entity, data[x, y]);
				active_block.[Friend]sprites[i] = null;
			}
			canvas.RemoveChild(active_block);
			state = .NeedNewBlock;

			// check for line clean up
			for (int j = 0; j < 20; j++)
			{
				for (int i = 0; i < 10; i++)
				{
					if (data[i, j] == null)
						break;
					if (i == 9)
					{
						// the line is full delete it
						for (int di = 0; di < 10; di++)
						{
							canvas.RemoveChild(data[di, j]);
							world.RemoveComponent(map_entity, data[di, j], true);
							data[di, j] = null;
						}

						cleard_block_combo++;
#if ARI_SERVER
						// send the punishment to the opponent
						if (cleard_block_combo > 1 && send_punishment_from != null)
							send_punishment_from(client_id);
#endif
						last_block_cleared = last_block;

						MoveBlocks(j + 1, true);
						j--;
					}
				}
			}

			// Apply the punishments
			if (is_player)
			{
				ApplyPunishment();
			}

		} // BlockReachedToEnd
	}
}
