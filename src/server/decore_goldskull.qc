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

/*QUAKED decore_goldskull (0 0.8 0.8) (-10 -10 -12) (10 10 12)
This is a decorative monster entity from Gunman Chronicles.

-------- KEYS --------
"targetname" : Name

-------- MODEL FOR RADIANT ONLY - DO NOT SET THIS AS A KEY --------
model="models/goldskull.mdl"
*/

class decore_goldskull:NSMonster
{
	void(void) decore_goldskull;
};

void
decore_goldskull::decore_goldskull(void)
{
	model = "models/goldskull.mdl";
	mins = [-10, -10, -12];
	maxs = [10, 10, 12];
}
