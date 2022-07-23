/*
 * Copyright (c) 2016-2022 Marco Cawthorne <marco@icculus.org>
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

/*QUAKED decore_cactus (0 0.8 0.8) (-16 -16 0) (16 16 64)
This is a decorative entity from Gunman Chronicles.
It will hurt the player whenever it gets touched.
The damage is 1 health point per second.

-------- KEYS --------
"targetname" : Name

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/cactus.mdl"
*/

class decore_cactus:RWDecore
{
	float m_flDmgTest;

	void(void) decore_cactus;

	virtual void(void) Respawn;
	virtual void(entity) StartTouch;
};

void
decore_cactus::StartTouch(entity eToucher)
{
	if (m_flDmgTest > time)
		return;

	if (eToucher.takedamage == DAMAGE_NO)
		return;

	NSSurfacePropEntity t = (NSSurfacePropEntity)eToucher;
	Damage_Apply(eToucher, this, 1, WEAPON_NONE, 0);
	m_flDmgTest = time + 1.0f;
}

void
decore_cactus::Respawn(void)
{
	super::Respawn();
	SetSolid(SOLID_BBOX);
}

void
decore_cactus::decore_cactus(void)
{
	model = "models/cactus.mdl";
	mins = [-16, -16, 0];
	maxs = [16, 16, 64];
	m_bDropToFloor = true;
}
