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

enum
{
	MG_IDLE, // 2.0f
	MG_FIDGET, // 2.6f
	MG_FIRE, // 0.333333f
	MG_SPINUP, // 2.0f
	MG_FIRELOOP, // 0.666667f
	MG_SPINDOWN, // 2.0f
	MG_DRAW, // 1.5f
	MG_IDLELOOP, // 0.666667f
	MG_HOLSTER // 1.5f
};

void
w_minigun_draw(player pl)
{
	pl.menu_active = 0;
	Weapons_SetModel("models/v_mechagun.mdl");
	Weapons_SetGeomset("geomset 1 1\n");
	Weapons_ViewAnimation(pl, MG_DRAW);
}

void
w_minigun_holster(player pl)
{
	Weapons_ViewAnimation(pl, MG_DRAW);
}

void
w_minigun_release(player pl)
{
	if (pl.w_idle_next) {
		return;
	}

	if (pl.menu_active == 1) {
		Weapons_ViewAnimation(pl, MG_IDLELOOP);
		pl.w_idle_next = 0.666667f;
		return;
	}

	int r  = (float)input_sequence % 5;
	switch (r) {
	case 0:
	case 1:
	case 2:
	case 3:
		Weapons_ViewAnimation(pl, MG_IDLE);
		pl.w_idle_next = 10.0f;
		break;
	default:
		Weapons_ViewAnimation(pl, MG_FIDGET);
		pl.w_idle_next = 2.0f;
	}
}

void
w_minigun_primary(player pl)
{
	vector src;
	if (pl.w_attack_next)
		return;

	if (pl.ammo_minigun <= 0) {
		w_minigun_release(pl);
		return;
	}

	src = Weapons_GetCameraPos(pl);

#ifdef SERVER
	Sound_Play(pl, CHAN_WEAPON, "weapon_minigun.fire");
#else
	View_SetMuzzleflash(MUZZLE_RIFLE);
#endif

	Weapons_ViewPunchAngle(pl, [-2,0,0]);


	pl.ammo_minigun--;

	if (pl.menu_active == 1) {
		Weapons_ViewAnimation(pl, MG_FIRELOOP);
#ifdef SERVER
		TraceAttack_FireBulletsWithDecal(1, src, Skill_GetValue("sk_9mmAR_bullet", 10), [0.1,0.1], WEAPON_MINIGUN, "Impact.BigShot");
#endif
		pl.w_attack_next = 0.1f;
		pl.w_idle_next = 0.1f;
	} else {
		Weapons_ViewAnimation(pl, MG_FIRE);
#ifdef SERVER
		TraceAttack_FireBulletsWithDecal(1, src, Skill_GetValue("sk_9mmAR_bullet", 10), [0.05,0.05], WEAPON_MINIGUN, "Impact.BigShot");
#endif
		pl.w_attack_next = 0.25f;
		pl.w_idle_next = 2.5f;
	}
}

void
w_minigun_secondary(player pl)
{
	if (pl.w_attack_next)
		return;

#ifdef SERVER
	if (pl.menu_active == 0) {
		//Sound_Play(pl, 8, "weapon_minigun.spinup");
	} else {
		//Sound_Play(pl, 8, "weapon_minigun.spindown");
	}
#endif

	if (pl.menu_active == 0) {
		Weapons_ViewAnimation(pl, MG_SPINUP);
	} else {
		Weapons_ViewAnimation(pl, MG_SPINDOWN);
	}

	pl.menu_active = 1 - pl.menu_active;

	pl.w_attack_next = 2.0f;
	pl.w_idle_next = 2.0f;
}

void
w_minigun_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_minigun, -1);
}

string
w_minigun_wmodel(void)
{
	return "models/w_mechagun.mdl";
}

string
w_minigun_pmodel(player pl)
{
	return "models/p_9mmar.mdl";
}

string
w_minigun_deathmsg(void)
{
	return "";
}

float
w_minigun_aimanim(player pl)
{
	return (0);
}

int
w_minigun_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (pl.ammo_minigun < 100) {
		pl.ammo_minigun = bound(0, pl.ammo_minigun + 30, 100);
	} else {
		return (0);
	}
#endif
	return (1);
}

void
w_minigun_hud(player pl)
{
#ifdef CLIENT
	vector pos;
	pos = g_hudmins + (g_hudres / 2) + [-23,-15];

	drawsubpic(
		pos,
		[47,31],
		g_cross_spr,
		[67/256,1/128],
		[47/256, 31/128],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);

	pos = g_hudmins + [g_hudres[0] - 125, g_hudres[1] - 42];
	for (int i = 0; i < 3; i++) {
		drawpic(
			pos,
			"gfx/vgui/640_ammo_minigun.tga",
			[32,16],
			[1,1,1],
			1.0f,
			DRAWFLAG_NORMAL
		);
		pos[1] += 8;
	}
	HUD_DrawAmmo2();
#endif
}

void
w_minigun_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	drawpic(
		pos,
		"gfx/vgui/640_weapon_minigun0.tga",
		[170,43],
		[1,1,1],
		a,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_minigun_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_minigun.fire");
	Sound_Precache("weapon_minigun.spindown");
	Sound_Precache("weapon_minigun.spinup");
#endif
	precache_model("models/v_mechagun.mdl");
	precache_model("models/w_mechagun.mdl");
	precache_model("models/p_9mmar.mdl");
}

weapon_t w_minigun =
{
	.name		= "minigun",
	.id			= ITEM_MINIGUN,
	.slot		= 2,
	.slot_pos	= 1,
	.draw		= w_minigun_draw,
	.holster	= w_minigun_holster,
	.primary	= w_minigun_primary,
	.secondary	= w_minigun_secondary,
	.reload		= __NULL__,
	.release	= w_minigun_release,
	.postdraw	= w_minigun_hud,
	.precache	= w_minigun_precache,
	.pickup		= w_minigun_pickup,
	.updateammo	= w_minigun_updateammo,
	.wmodel		= w_minigun_wmodel,
	.pmodel		= w_minigun_pmodel,
	.deathmsg	= w_minigun_deathmsg,
	.aimanim	= w_minigun_aimanim,
	.type		= gunman_wpntype_ranged,
	.hudpic		= w_minigun_hudpic
};
