class
RWDecore:NSSurfacePropEntity
{
	bool m_bDropToFloor;

	void(void) RWDecore;

	virtual void(void) Respawn;
};

void
RWDecore::Respawn(void)
{
	vector newmins = mins;
	vector newmaxs = maxs;

	SetOrigin(GetSpawnOrigin());
	SetModel(GetSpawnModel());
	SetSize(newmins, newmaxs);

	if (m_bDropToFloor == true)
		DropToFloor();
}

void
RWDecore::RWDecore(void)
{
}