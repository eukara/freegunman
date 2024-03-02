/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

typedef enum
{
	HOLODAMAGE_BEAK = 0,
	HOLODAMAGE_TUBE,
	HOLODAMAGE_RAPTOR
} holoDamageMonster_t;

typedef enum
{
	HOLOFILTER_GAUSSPULSE = 0,
	HOLOFILTER_GAUSSCHARGED,
	HOLOFILTER_GAUSSRAPID,
	HOLOFILTER_GAUSSSNIPER,
	HOLOFILTER_BULLET,
	HOLOFILTER_CHEMGUNACID,
	HOLOFILTER_CHEMGUNBASE,
	HOLOFILTER_CHEMGUNEXPLOSIVE,
	HOLOFILTER_CHEMGUNSMOKE,
} holoDamageType_t;

/*!QUAKED hologram_damage (0 0.8 0.8) (-16 -16 0) (16 16 72)
# OVERVIEW
A holographic creature, which will talk to an entity_spritegod when damaged.

# KEYS
- "targetname" : Name
- "target" : Name of the entity_spritegod to talk to.
- "creaturetype" : Monster id. 0 = Beak, 1 = Tube, 2 = Raptor.
- "damagetype" : Damage type filter. Will only react to the specified type.
- "targetfail" : The entity to trigger when the damage type filter fails.

# NOTES
Choose one of the following numbers ids (0-8) for `damagetype`:

0. Gauss Pulse-Shot
1. Gauss Charged-Shot
2. Gauss Rapid-Shot
3. Gauss Sniper-Shot
4. Bullet (Shotgun, Minigun)
5. Chemgun Acid
6. Chemgun Base
7. Chemgun Explosive
8. Chemgun Smoke

# TRIVIA
This entity was introduced in Gunman Chronicles (2000).
*/
class
hologram_damage:NSTalkMonster
{
public:
	void hologram_damage(void);

	virtual void SpawnKey(string, string);
	virtual void Spawned(void);
	virtual void Respawn(void);
	virtual void Pain(void);

	nonvirtual void Fail(void);

private:
	string m_strFailName;
	holoDamageMonster_t m_dType;
	holoDamageType_t m_dDamageType;
};

void
hologram_damage::hologram_damage(void)
{
	m_strFailName = __NULL__;
	m_dType = HOLODAMAGE_BEAK;
	m_dDamageType = HOLOFILTER_BULLET;
}

void
hologram_damage::Spawned(void)
{
	super::Spawned();

	switch (m_dType) {
	case 1:
		model = "models/tube.mdl";
		break;
	case 2:
		model = "models/raptor.mdl";
		break;
	default:
		model = "models/beak.mdl";
	}

	precache_model(model);
	m_oldModel = model;
}

void
hologram_damage::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "targetfail":
		m_strFailName = ReadString(strValue);
		break;
	case "creaturetype":
		m_dType = ReadFloat(strValue);
		break;
	case "damagetype":
		m_dDamageType = ReadFloat(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
hologram_damage::Respawn(void)
{
	super::Respawn();

	SetModel(GetSpawnModel());
	SetOrigin(GetSpawnOrigin());
	SetSolid(SOLID_CORPSE);
	SetMovetype(MOVETYPE_NONE);
	SetRenderMode(RM_ADDITIVE);
	SetTakedamage(DAMAGE_AIM);
	SetHealth(1000);
	SetSize([-16,-16,0], [16,16,72]);
	DropToFloor();
}

void
hologram_damage::Fail(void)
{
	string oldTarget = target;
	target = m_strFailName;
	EntLog("Wrong weapon type, triggering `targetfail` %S", target);
	UseTargets(this, TRIG_TOGGLE, 0.0f);
	target = oldTarget;
}

void
hologram_damage::Pain(void)
{
	entity_digitgod digitGod = (entity_digitgod)find(world, ::targetname, target);

	if (!target || !digitGod) {
		EntError("entity_digitgod %S not found!", target);
		return;
	}

	/* TODO: support the weapon modes properly, hah... */
	switch (m_dDamageType) {
	case HOLOFILTER_GAUSSPULSE:
	case HOLOFILTER_GAUSSCHARGED:
	case HOLOFILTER_GAUSSRAPID:
	case HOLOFILTER_GAUSSSNIPER:
		if (g_dmg_iWeapon != WEAPON_GAUSSPISTOL) {
			Fail();
			return;
		}
		break;
	case HOLOFILTER_BULLET:
		if (!(g_dmg_iWeapon == WEAPON_SHOTGUN || g_dmg_iWeapon == WEAPON_MINIGUN)) {
			Fail();
			return;
		}
		break;
	case HOLOFILTER_CHEMGUNACID:
	case HOLOFILTER_CHEMGUNBASE:
	case HOLOFILTER_CHEMGUNEXPLOSIVE:
	case HOLOFILTER_CHEMGUNSMOKE:
		if (g_dmg_iWeapon != WEAPON_GAUSSPISTOL) {
			Fail();
			return;
		}
		break;
	default:
		return;
	}

	EntLog("Hologram informing %S about %i damage taken", target, g_dmg_iRealDamage);
	digitGod.AddToCounter(g_dmg_iRealDamage);
	SetHealth(1000);
}