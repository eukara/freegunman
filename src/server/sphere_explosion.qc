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

/*QUAKED sphere_explosion (0 0.8 0.8) (-16 -16 -16) (16 16 16)
This is Gunman Chronicles' fancy explosion with its own set of parameters.
Currently we just wrap it to call FX_Explosion.

-------- KEYS --------
"targetname"    : Name
"maxradius"     : Explosion radius.
"radiusstep"    : Expansion step in units.
"trans"         : Starting transparency of the sphere (0-255)
"transstep"     : Fade out steps.
"numtracers"    : Number of traces, 0 = None, 1 = Fifteen.
"shockwave"     : Shockwave ring visible? 0 = No, 1 = Yes
"implosion"     : Implosion? 0 = No, 1 = Yes
"shakeduration" : Duration of screen shake in seconds.
"fadeholdtime"  : Fade effect hold time.
"fadetime"      : Fade effect time.

-------- TRIVIA --------
This entity was introduced in Gunman Chronicles (2000).
*/

class
sphere_explosion:NSPointTrigger
{
#if 0
	float m_flMaxRadius;	/* Explosion Radius */
	int m_iRadiusStep;		/* Speed of Expansion */
	int m_iTrans;			/* Starting transparency of 'sphere' */
	int m_iTransStep;		/* Fade out steps */
	int m_iNumTracers;		/* 0 - None, 1 = Fifteen (???) */
	bool m_bShockwave;		/* Shockwave ring, no/yes */
	bool m_bImplosion;		/* Implosion, no/yes */
	float m_flShakeDuration;/* Duration of shake in seconds */
	float m_flFadeHoldTime;
	float m_flFadeTime;
#endif
	
	void(void) sphere_explosion;

	virtual void(void) Respawn;
	virtual void(string, string) SpawnKey;
	virtual void(entity, triggermode_t) Trigger;
};

void
sphere_explosion::Trigger(entity eAct, triggermode_t iState)
{
	pointparticles(particleeffectnum("fx_explosion.main"), origin, [0,0,0], 1);
}

void
sphere_explosion::Respawn(void)
{
	SetOrigin(GetSpawnOrigin());
	SetSize([0,0,0], [0,0,0]);
}

void
sphere_explosion::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {

#if 0
	case "maxradius":
		m_flMaxRadius = stof(strValue);
		break;
	case "radiusstep":
		m_iRadiusStep = stoi(strValue);
		break;
	case "trans":
		m_iTrans = stoi(strValue);
		break;
	case "transstep":
		m_iTransStep = stoi(strValue);
		break;
	case "numtracers":
		m_iNumTracers = stoi(strValue);
		break;
	case "shockwave":
		m_bShockwave = stof(strValue) == 1 ? true : false;
		break;
	case "implosion":
		m_bImplosion = stof(strValue) == 1 ? true : false;
		break;
	case "shakeduration":
		m_flShakeDuration = stof(strValue);
		break;
	case "fadeholdtime":
		m_flFadeHoldTime = stof(strValue);
		break;
	case "fadetime":
		m_flFadeTime = stof(strValue);
		break;
#endif
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
sphere_explosion::sphere_explosion(void)
{

}