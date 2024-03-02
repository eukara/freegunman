/*
 * Copyright (c) 2022 Marco Cawthorne <marco@icculus.org>
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

/*!QUAKED entity_spritegod (0 0.8 0.8) (-16 -16 -16) (16 16 16)
# OVERVIEW
Master entity for emitting a series of sprites.

# KEYS
- "targetname" : Name
- "spritename" : Sprite model to emit
- "spritenoise" : Unknown.
- "spritestartstate" : Whether to start off (0) or on (1)
- "spritecount" : How many sprites to emit per interval
- "spritefreq" : Emitting frequency, defaults to 5.
- "spritex" : Direction on the X-Axis (?)
- "spritey" : Direction on the Y-Axis (?)
- "spritez" : Direction on the Z-Axis (?)
- "targetent" : Target entity, maybe used for setting the direction alternatively (?)

# TRIVIA
This entity was introduced in Gunman Chronicles (2000).
*/
class
entity_spritegod:NSPointTrigger
{
public:
	void(void) entity_spritegod;

	virtual void(string, string) SpawnKey;
	virtual void(void) Spawned;
	virtual void(void) Respawn;
	virtual void(entity, triggermode_t) Trigger;
	virtual void(void) StartTimer;
	virtual void(void) EmitSprite;

private:
	string m_strSprite;
	int m_iNoise;
	float m_flSpeed;
	bool m_bState;
	int m_iCount;
	float m_iFrequency;
	vector m_vecDirection;
	string m_strTargetEnt;
};

void
entity_spritegod::entity_spritegod(void)
{
	m_strSprite = __NULL__;
	m_iNoise = 50;
	m_flSpeed = 100;
	m_bState = false;
	m_iCount = 1;
	m_iFrequency = 5;
	m_vecDirection = [0,0,0];
	m_strTargetEnt = __NULL__;
}

void
entity_spritegod::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "spritename":
		m_strSprite = strValue;
		break;
	case "spritenoise":
		m_iNoise = stoi(strValue); /* I have no idea what this does */
		break;
	case "spritespeed":
		m_flSpeed = stof(strValue);
		break;
	case "spritestartstate":
		m_bState = stof(strValue);
		break;
	case "spritecount":
		m_iCount = stoi(strValue);
		break;
	case "spritefreq":
		m_iFrequency = stof(strValue);
		break;
	case "spritex":
		m_vecDirection[0] = stof(strValue);
		break;
	case "spritey":
		m_vecDirection[1] = stof(strValue);
		break;
	case "spritez":
		m_vecDirection[2] = stof(strValue);
		break;
	case "targetent":
		m_strTargetEnt = strValue;
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
entity_spritegod::Spawned(void)
{
	super::Spawned();

	precache_model(m_strSprite);
}

void
entity_spritegod::Respawn(void)
{
	SetSize([0,0,0], [0,0,0]);
	SetOrigin(GetSpawnOrigin());
	SetThink(EmitSprite);

	if (m_bState == true)
		m_iValue = 1;

	if (m_iValue)
		StartTimer();
}

void
entity_spritegod::Trigger(entity eAct, triggermode_t iState)
{
	switch (iState) {
	case TRIG_OFF:
		m_iValue = 0;
		break;
	case TRIG_ON:
		m_iValue = 1;
		break;
	case TRIG_TOGGLE:
		m_iValue = 1 - m_iValue;
		break;
	}

	if (m_iValue)
		StartTimer();
}

void
entity_spritegod::StartTimer(void)
{
	SetNextThink(m_iFrequency / 100);
}

void
entity_spritegod::EmitSprite(void)
{
	for (int i = 0; i < m_iCount; i++) {
		env_sprite new = spawn(env_sprite);
		new.SetOrigin(GetOrigin());
		new.SetModel(m_strSprite);
		new.SetMovetype(MOVETYPE_NOCLIP);

		/* I have no idea what I'm doing, seems to be an offset? wtf? */
		makevectors(vectoangles(origin - (origin + m_vecDirection)));
		new.SetVelocity(v_forward * m_flSpeed);
		new.ScheduleThink(Destroy, 1.0);
	}

	if (m_iValue)
		StartTimer();
}
