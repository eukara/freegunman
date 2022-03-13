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

/* Weapon Indices for the weapon table */
enum
{
	WEAPON_NONE,
	WEAPON_FISTS, // 0
	WEAPON_AICORE,
	WEAPON_GAUSSPISTOL, // 1
	WEAPON_SHOTGUN, // 2
	WEAPON_MINIGUN, // 2
	WEAPON_BEAMGUN, // 3
	WEAPON_DML, // 3
	WEAPON_GRENADE,
	WEAPON_CHEMICALGUN
};

/* weight table... I just guessed this was a good compromise */
enum
{
	WEIGHT_AICORE,
	WEIGHT_NONE,
	WEIGHT_FISTS,
	WEIGHT_GRENADE,
	WEIGHT_GAUSSPISTOL,
	WEIGHT_DML,
	WEIGHT_SHOTGUN,
	WEIGHT_MINIGUN,
	WEIGHT_BEAMGUN,
	WEIGHT_CHEMICALGUN
};

weapontype_t gunman_wpntype_ranged(void)
{
	return WPNTYPE_RANGED;
}

weapontype_t gunman_wpntype_close(void)
{
	return WPNTYPE_CLOSE;
}

weapontype_t gunman_wpntype_throw(void)
{
	return WPNTYPE_THROW;
}
