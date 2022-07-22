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

/*QUAKED decore_asteroid (0 0.8 0.8) (-16 -16 0) (16 16 40)
This is a decorative entity from Gunman Chronicles.

-------- KEYS --------
"targetname" : Name

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/rockspin.mdl"
*/

class decore_asteroid:RWDecore
{
	void(void) decore_asteroid;

	virtual void(string, string) SpawnKey;
};

void
decore_asteroid::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "asteroidsize":
		SetBody(stoi(strValue) + 1);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
decore_asteroid::decore_asteroid(void)
{
	model = "models/rockspin.mdl";
	mins = [-16, -16, 0];
	maxs = [16, 16, 40];
}
