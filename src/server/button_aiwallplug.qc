class
button_aiwallplug:NSRenderableEntity
{
public:
	void button_aiwallplug(void);

	virtual void Precache(void);
	virtual void Respawn(void);
};

void
button_aiwallplug::button_aiwallplug(void)
{

}

void
button_aiwallplug::Precache(void)
{
	precache_model("models/aiwallplug.mdl");
}

void
button_aiwallplug::Respawn(void)
{
	SetSolid(SOLID_BBOX);
	SetMovetype(MOVETYPE_NONE);
	SetModel("models/aiwallplug.mdl");
	SetSize([-32,-32,0], [32,32,48]);
	SetOrigin(GetSpawnOrigin());
	SetAngles(GetSpawnAngles());
}