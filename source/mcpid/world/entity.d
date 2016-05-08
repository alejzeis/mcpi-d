module mcpid.world.entity;

import mcpid.player;
import mcpid.net.network;
import mcpid.net.entity;

class Entity {
	protected shared uint entityId;
	protected shared bool spawned = false;
	
	protected shared bool fire = false;
	protected shared bool crouched = false;
	protected shared short item = 2;
	protected shared short itemMeta = 0;
	protected shared short air = 300;
	
	protected shared float x;
	protected shared float y;
	protected shared float z;
	
	this(shared float x, shared float y, shared float z) {
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	protected shared byte[] getMetadata() {
		import draklib.bytestream;
		
		ByteStream bs = ByteStream.alloc(1024);
		byte flags = 0;
		flags |= fire ? 0 : 1;
		flags |= (crouched ? 1 : 0) << 1;
		
		bs.write(writeMetadataEntry(0, Metadata!byte(MetadataType.BYTE, flags)));
		bs.write(writeMetadataEntry(1, Metadata!short(MetadataType.SHORT, air)));
		bs.write(writeMetadataEntry(16, Metadata!byte(MetadataType.BYTE, cast(byte) 0)));
		bs.write(writeMetadataEntry(17, Metadata!(int[])(MetadataType.INT_ARRAY, [0, 0, 0])));
		bs.writeUByte(0x7F); //End char
		return bs.getBuffer()[0..bs.getPosition()].dup;
	}
	
	public shared void spawnTo(shared Player player) {
		if(typeid(this) == typeid(Player)) {
			AddPlayerPacket app = AddPlayerPacket();
			app.clientID = 0;
			app.username = (cast(shared Player) this).getUsername();
			app.entityId = entityId;
			app.x = x;
			app.y = y;
			app.z = z;
			app.metadata = getMetadata();
			player.sendPacket(cast(shared) encodeStruct(app));
			
			PlayerEquipmentPacket pep = PlayerEquipmentPacket();
			pep.entityId = entityId;
			pep.block = item;
			pep.meta = itemMeta;
			player.sendPacket(cast(shared) encodeStruct(pep));
		}
	}
}