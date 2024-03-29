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
	GP_IDLE1, // 3.75f
	GP_IDLE2, // 3.0f
	GP_FIRESINGLE, // 0.727273f
	GP_FIREFAST, // 0.2f
	GP_FIRECHARGE, // 3.0f
	GP_DRAW, // 1.071429f
	GP_HOLSTER, // 0.9375f
	SNIPER_IDLE1, // 3.0f
	SNIPER_IDLE2, // 3.0f
	SNIPER_FIDGET, // 3.0f
	SNIPER_SHOOT, // 0.357143
	SNIPER_DRAW, // 0.937500
	SNIPER_HOLSTER // 1.666667f
};

enum
{
	GM_SINGLE,
	GM_CHARGE,
	GM_FAST,
	GM_SNIPER
};

void
w_gausspistol_draw(player pl)
{
	pl.menu_active = 0;
	Weapons_SetModel("models/v_guasspistol.mdl");
	Weapons_SetGeomset("geomset 1 1\n");
	Weapons_ViewAnimation(pl, GP_DRAW);
}

void
w_gausspistol_holster(player pl)
{
	Weapons_ViewAnimation(pl, GP_HOLSTER);
}

void
w_gausspistol_release(player pl)
{

	if (pl.w_idle_next) {
		return;
	}

	int r  = floor(pseudorandom() * 5.0f);
	switch (r) {
	case 0:
	case 1:
	case 2:
	case 3:
		Weapons_ViewAnimation(pl, GP_IDLE1);
		pl.w_idle_next = 3.75f;
		break;
	default:
		Weapons_ViewAnimation(pl, GP_IDLE2);
		pl.w_idle_next = 3.0f;
	}
}

#ifdef SERVER
void
w_gausspistol_firecharge(vector pos, player pl)
{
	static void w_gausspistol_firecharge_impact(entity target, entity source) {
		Damage_Apply(target, source.owner, Skill_GetValue("sk_gaussslow_d", 50), WEAPON_GAUSSPISTOL, DMG_GENERIC);
	}

	NSProjectile ball = spawn(NSProjectile);
	ball.SetModel("sprites/gausswomp.spr");
	ball.SetRenderMode(RM_ADDITIVE);
	ball.SetOwner(pl);
	ball.SetImpact(w_gausspistol_firecharge_impact);

	makevectors(pl.v_angle);
	ball.SetOrigin(pos + (v_forward * 8));
	ball.SetVelocity(v_forward * 500);
}

void
w_gausspistol_firerapid(vector pos, player pl)
{
	static void w_gausspistol_firerapid_impact(entity target, entity source) {
		Damage_Apply(target, source.owner, Skill_GetValue("sk_gaussfast_d", 13), WEAPON_GAUSSPISTOL, DMG_GENERIC);
	}

	NSProjectile ball = spawn(NSProjectile);
	ball.SetModel("sprites/gausswomp.spr");
	ball.SetScale(0.25f);
	ball.SetRenderMode(RM_ADDITIVE);
	ball.SetOwner(pl);
	ball.SetImpact(w_gausspistol_firerapid_impact);

	makevectors(pl.v_angle);
	ball.SetOrigin(pos + (v_forward * 8));
	ball.SetVelocity(v_forward * 500);
}
#endif

void
w_gausspistol_primary(player pl)
{
	vector src;
	int take = 1;

	if (pl.menu_active > 0) {
		pl.menu_active = 0;
		pl.gflags |= GF_SEMI_TOGGLED;
		pl.w_attack_next = 0.25f;
		return;
	}

	if (pl.gflags & GF_SEMI_TOGGLED) {
		return;
	}
	
	if (pl.menu_active > 0) {
		pl.menu_active = 0;
		pl.gflags |= GF_SEMI_TOGGLED;
		return;
	}

	if (pl.w_attack_next > 0) {
		return;
	}

	/* ammo check */
	if (pl.ammo_gauss <= 0) {
		return;
	}

	if (pl.gauss_mode == GM_CHARGE && pl.ammo_gauss < 10) {
		return;
	}

	switch (pl.gauss_mode) {
	case GM_FAST:
		Weapons_ViewAnimation(pl, GP_FIREFAST);
#ifdef SERVER
		w_gausspistol_firerapid(Weapons_GetCameraPos(pl), pl);
		Sound_Play(pl, CHAN_WEAPON, "weapon_gausspistol.firefast");
#endif
		pl.w_attack_next = 0.1f;
		pl.w_idle_next = 2.5f;
		break;
	case GM_CHARGE:
		take = 10;
		Weapons_ViewAnimation(pl, GP_FIRECHARGE);
#ifdef SERVER
		w_gausspistol_firecharge(Weapons_GetCameraPos(pl), pl);
		Sound_Play(pl, CHAN_WEAPON, "weapon_gausspistol.firecharge");
		Sound_Play(pl, 8, "weapon_gausspistol.charge");
#endif
		pl.w_attack_next = 2.0f;
		pl.w_idle_next = 5.0f;
		break;
	default:
		pl.gflags |= GF_SEMI_TOGGLED;
		Weapons_ViewAnimation(pl, GP_FIRESINGLE);
#ifdef SERVER
		traceline(Weapons_GetCameraPos(pl), Weapons_GetCameraPos(pl) + (v_forward * 1024),\
			FALSE, pl);

		if (trace_fraction <= 1.0) {
			if (trace_ent.takedamage == DAMAGE_YES) {
				Damage_Apply(trace_ent, pl, Skill_GetValue("sk_gaussshot_d", 10), WEAPON_GAUSSPISTOL, DMG_GENERIC);
			}

		}
		FX_GaussBeam(Weapons_GetCameraPos(pl), input_angles, pl);
		Sound_Play(pl, CHAN_WEAPON, "weapon_gausspistol.firesingle");
#endif
		pl.w_attack_next = 0.15f;
		pl.w_idle_next = 2.5f;
		break;
	}

	src = Weapons_GetCameraPos(pl);

#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_WEIRD);
#endif

	pl.ammo_gauss -= take;
	Weapons_ViewPunchAngle(pl, [-5,0,0]);
}

void
w_gausspistol_secondary(player pl)
{

	if (pl.gflags & GF_SEMI_TOGGLED) {
		return;
	}

	pl.gflags |= GF_SEMI_TOGGLED;

	/* activate menu */
	pl.menu_active = 1;
	w_gausspistol_release(pl);
}

void
w_gausspistol_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_gauss, pl.gauss_mode);
}

string
w_gausspistol_wmodel(void)
{
	return "models/w_gauss.mdl";
}

string
w_gausspistol_pmodel(player pl)
{
	return "models/p_357.mdl";
}

string
w_gausspistol_deathmsg(void)
{
	return "%s kills %s with his Gauss-Pistol";
}

float
w_gausspistol_aimanim(player pl)
{
	return (0);
}

int
w_gausspistol_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (pl.ammo_gauss < 150) {
		pl.ammo_gauss = bound(0, pl.ammo_gauss + 35, 150);
	} else {
		return (0);
	}
#endif
	return (1);
}

void
w_gausspistol_hud(player pl)
{
#ifdef CLIENT
	vector pos;

	pos = g_hudmins + [g_hudres[0] - 125, g_hudres[1] - 42];
	for (int i = 0; i < 3; i++) {
		drawpic(
			pos,
			"gfx/vgui/640_ammo_gauss.tga",
			[32,16],
			[1,1,1],
			1.0f,
			DRAWFLAG_NORMAL
		);
		pos[1] += 8;
	}

	HUD_DrawAmmo2();
	
	/* menu */
	if (pl.menu_active > 0) {
		pos = g_hudmins + (g_hudres / 2) + [-96,-72];

		/* far left */
		if (pl.gauss_mode == GM_SINGLE) {
			drawsubpic(
				pos,
				[64,144],
				"sprites/gausshud2.spr_0.tga",
				[0/192,0/144],
				[64/192, 144/144],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
			drawsubpic(
				pos + [64,0],
				[128,144],
				"sprites/gausshud1.spr_0.tga",
				[64/192,0/144],
				[128/192, 144/144],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		}
		if (pl.gauss_mode == GM_CHARGE) {
			drawsubpic(
				pos,
				[64,144],
				"sprites/gausshud1.spr_0.tga",
				[0/192,0/144],
				[64/192, 144/144],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
			drawsubpic(
				pos + [64,0],
				[64,144],
				"sprites/gausshud2.spr_0.tga",
				[64/192,0/144],
				[64/192, 144/144],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
			drawsubpic(
				pos + [128,0],
				[64,144],
				"sprites/gausshud1.spr_0.tga",
				[128/192,0/144],
				[64/192, 144/144],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		}
		if (pl.gauss_mode == GM_FAST) {
			drawsubpic(
				pos,
				[128,144],
				"sprites/gausshud1.spr_0.tga",
				[0/192,0/144],
				[128/192, 144/144],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
			drawsubpic(
				pos + [128,0],
				[64,144],
				"sprites/gausshud2.spr_0.tga",
				[128/192,0/144],
				[64/192, 144/144],
				[1,1,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		}
		return;
	}

	pos = g_hudmins + (g_hudres / 2) + [-15,-15];
	drawsubpic(
		pos,
		[31,31],
		g_cross_spr,
		[1/256,1/128],
		[31/256, 31/128],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_gausspistol_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	drawpic(
		pos,
		"gfx/vgui/640_weapon_gaussPistol0.tga",
		[170,43],
		[1,1,1],
		a,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_gausspistol_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_gausspistol.charge");
	Sound_Precache("weapon_gausspistol.firecharge");
	Sound_Precache("weapon_gausspistol.firefast");
	Sound_Precache("weapon_gausspistol.firesingle");
#endif

	precache_model("models/v_guasspistol.mdl");
	precache_model("sprites/gausshud1.spr");
	precache_model("sprites/gausshud2.spr");
	precache_model("sprites/gausswomp.spr");

}

weapon_t w_gausspistol =
{
	.name		= "gausspistol",
	.id			= ITEM_GAUSSPISTOL,
	.weight		= WEIGHT_GAUSSPISTOL,
	.slot		= 1,
	.slot_pos	= 0,
	.draw		= w_gausspistol_draw,
	.holster	= w_gausspistol_holster,
	.primary	= w_gausspistol_primary,
	.secondary	= w_gausspistol_secondary,
	.reload		= __NULL__,
	.release	= w_gausspistol_release,
	.postdraw	= w_gausspistol_hud,
	.precache	= w_gausspistol_precache,
	.pickup		= w_gausspistol_pickup,
	.updateammo	= w_gausspistol_updateammo,
	.wmodel		= w_gausspistol_wmodel,
	.pmodel		= w_gausspistol_pmodel,
	.deathmsg	= w_gausspistol_deathmsg,
	.aimanim	= w_gausspistol_aimanim,
	.type		= gunman_wpntype_ranged,
	.hudpic		= w_gausspistol_hudpic
};

#ifdef CLIENT
int
w_gausspistol_hudforward(player pl)
{
	if (pl.menu_active <= 0) {
		return (1);
	}

	pl.gauss_mode = bound(GM_SINGLE, pl.gauss_mode - 1, GM_FAST);
	sendevent("w_gp_setmode", "i", pl.gauss_mode);
	return (0);
}

int
w_gausspistol_hudback(player pl)
{
	if (pl.menu_active <= 0) {
		return (1);
	}

	pl.gauss_mode = bound(GM_SINGLE, pl.gauss_mode + 1, GM_FAST);
	sendevent("w_gp_setmode", "i", pl.gauss_mode);
	return (0);
}
#else
void
CSEv_w_gp_setmode_i(int f)
{
	player pl = (player)self;
	pl.gauss_mode = f;
}
#endif
