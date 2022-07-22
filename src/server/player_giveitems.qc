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

typedef enumflags
{
	GIFL_FISTS,
	GIFL_PISTOL,
	GIFL_SNIPER,
	GIFL_SHOTGUN,
	GIFL_MECHAGUN,
	GIFL_COOLERS,
	GIFL_BEAMGUN,
	GIFL_DML,
	GIFL_CHEMGUN,
	GIFL_AICORE,
	GIFL_ARMOR,
	GIFL_HEALTHKIT1,
	GIFL_HEALTHKIT2,
	GIFL_HEALTHKIT3,
	GIFL_HEALTHKIT4,
};

class
player_giveitems:NSPointTrigger
{
	void(void) player_giveitems;

	virtual void(entity, int) Trigger;
};

void
player_giveitems::Trigger(entity eAct, int iState)
{
	player pl = (player)eAct;

	if (!(eAct.flags & FL_CLIENT))
		return;

	if (HasSpawnFlags(GIFL_FISTS))
		Weapons_AddItem(pl, WEAPON_FISTS, -1);

	if (HasSpawnFlags(GIFL_PISTOL))
		Weapons_AddItem(pl, WEAPON_GAUSSPISTOL, -1);

	if (HasSpawnFlags(GIFL_SNIPER))
		Weapons_AddItem(pl, WEAPON_GAUSSPISTOL, -1);

	if (HasSpawnFlags(GIFL_SHOTGUN))
		Weapons_AddItem(pl, WEAPON_SHOTGUN, -1);

	if (HasSpawnFlags(GIFL_MECHAGUN))
		Weapons_AddItem(pl, WEAPON_MINIGUN, -1);

	if (HasSpawnFlags(GIFL_COOLERS))
		Weapons_AddItem(pl, WEAPON_GAUSSPISTOL, -1);

	if (HasSpawnFlags(GIFL_BEAMGUN))
		Weapons_AddItem(pl, WEAPON_BEAMGUN, -1);

	if (HasSpawnFlags(GIFL_DML))
		Weapons_AddItem(pl, WEAPON_DML, -1);

	if (HasSpawnFlags(GIFL_CHEMGUN))
		Weapons_AddItem(pl, WEAPON_CHEMICALGUN, -1);

	if (HasSpawnFlags(GIFL_AICORE))
		Weapons_AddItem(pl, WEAPON_AICORE, -1);

	if (HasSpawnFlags(GIFL_ARMOR))
		Weapons_AddItem(pl, WEAPON_GAUSSPISTOL, -1);

	if (HasSpawnFlags(GIFL_HEALTHKIT1))
		Weapons_AddItem(pl, WEAPON_GAUSSPISTOL, -1);

	if (HasSpawnFlags(GIFL_HEALTHKIT2))
		Weapons_AddItem(pl, WEAPON_GAUSSPISTOL, -1);

	if (HasSpawnFlags(GIFL_HEALTHKIT3))
		Weapons_AddItem(pl, WEAPON_GAUSSPISTOL, -1);

	if (HasSpawnFlags(GIFL_HEALTHKIT4))
		Weapons_AddItem(pl, WEAPON_GAUSSPISTOL, -1);
}

void
player_giveitems::player_giveitems(void)
{

}