/*
 * Copyright (c) 2019-2023 Marco Cawthorne <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

class
RWDecore:NSSurfacePropEntity
{
public:
	void(void) RWDecore;

	virtual void SpawnKey(string, string);
	virtual void(void) Respawn;
	virtual void StartTouch(entity);

private:
	bool m_bDropToFloor;
	vector m_vecSpawnMins;
	vector m_vecSpawnMaxs;
	bool m_bIsSolid;
	int m_iDamage;
	float m_flDamageTime;
	float m_flDamageTest;
	int m_iSpawnFrame;
};

void
RWDecore::RWDecore(void)
{
	m_bDropToFloor = false;
	m_vecSpawnMins = g_vec_null;
	m_vecSpawnMaxs = g_vec_null;
	m_bIsSolid = false;
	m_iDamage = 0i;
	m_flDamageTime = 0.0;
	m_flDamageTest = 0.0f;
	m_iSpawnFrame = 0i;
}

void
RWDecore::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "mins":
		m_vecSpawnMins = ReadVector(strValue);
		break;
	case "maxs":
		m_vecSpawnMaxs = ReadVector(strValue);
		break;
	case "droptofloor":
		m_bDropToFloor = ReadBool(strValue);
		break;
	case "solid":
		m_bIsSolid = ReadBool(strValue);
		break;
	case "damage":
		m_iDamage = ReadInt(strValue);
		break;
	case "dmgtime":
		m_flDamageTime = ReadFloat(strValue);
		break;
	case "rotate":
		avelocity[0] = random(-32, 32);
		avelocity[1] = random(-32, 32);
		avelocity[2] = random(-32, 32);
		movetype = MOVETYPE_NOCLIP;
		break;
	case "frame":
		m_iSpawnFrame = ReadInt(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
		break;
	}
}

void
RWDecore::Respawn(void)
{
	if (m_bIsSolid == true)
		SetSolid(SOLID_BBOX);
	else
		SetSolid(SOLID_NOT);

	SetOrigin(GetSpawnOrigin());
	SetModel(GetSpawnModel());
	SetSize(m_vecSpawnMins, m_vecSpawnMaxs);
	SetFrame(m_iSpawnFrame);

	if (m_bDropToFloor == true)
		DropToFloor();
}

void
RWDecore::StartTouch(entity touchingEntity)
{
	if (m_flDamageTest > time)
		return;

	if (touchingEntity.takedamage == DAMAGE_NO)
		return;

	Damage_Apply(touchingEntity, this, m_iDamage, WEAPON_NONE, 0);
	m_flDamageTest = time + m_flDamageTime;
}