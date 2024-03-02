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
	FISTS_IDLE, // 2.0f
	FISTS_FIDGET1, // 3.0f
	FISTS_FIDGET2, // 2.333333f
	FISTS_RIGHT, // 0.419355f
	FISTS_LEFT, // 0.419355f
	FISTS_DOUBLE, // 0.739130f
	FISTS_DRAW, // 1.4f
	FISTS_HOLSTER, // 0.7f
	KNIFE_DRAW, // 0.75f
	KNIFE_HOLSTER, // 0.75f
	KNIFE_IDLE, // 2.0f
	KNIFE_FIDGET, // 2.0f
	KNIFE_ATTACK1, // 0.789474f
	KNIFE_ATTACK2, // 0.421053f
	HANDS_PUSHBUTTON, // 8.0f
};

enum
{
	HS_KNIFE,
	HS_KNIFE_TO_FISTS,
	HS_FISTS,
	HS_FISTS_TO_KNIFE
};

void
w_fists_updateammo(player pl)
{
#ifdef SERVER
	Weapons_UpdateAmmo(pl, -1, -1, pl.fist_mode);
#endif
}

void
w_fists_draw(player pl)
{
	pl.menu_active = 0;
	Weapons_SetModel("models/v_hands.mdl");

	if (pl.fist_mode == HS_KNIFE) {
#ifdef SERVER
		Sound_Play(pl, CHAN_WEAPON, "weapon_fists.knifedraw");
#endif
		Weapons_ViewAnimation(pl, KNIFE_DRAW);
		Weapons_SetGeomset("geomset 1 2\n");
		pl.w_attack_next = 0.75f;
		pl.w_idle_next = pl.w_attack_next;
	} else if (pl.fist_mode == HS_FISTS) {
		Weapons_ViewAnimation(pl, FISTS_DRAW);
		Weapons_SetGeomset("geomset 1 1\n");
		pl.fist_mode = HS_FISTS;
		pl.w_attack_next = 1.4f;
		pl.w_idle_next = pl.w_attack_next;
	}
}

void
w_fists_holster(player pl)
{
	Weapons_ViewAnimation(pl, KNIFE_HOLSTER);
}

void
w_fists_release(player pl)
{
	int r;

	if (pl.w_idle_next) {
		return;
	}

	if (pl.fist_mode == HS_FISTS_TO_KNIFE) {
#ifdef SERVER
		Sound_Play(pl, CHAN_WEAPON, "weapon_fists.knifedraw");
#endif
		Weapons_ViewAnimation(pl, KNIFE_DRAW);
		Weapons_SetGeomset("geomset 1 2\n");
		pl.fist_mode = HS_KNIFE;
		pl.w_attack_next = 0.75f;
		pl.w_idle_next = pl.w_attack_next;
		return;
	} else if (pl.fist_mode == HS_KNIFE_TO_FISTS) {
		Weapons_ViewAnimation(pl, FISTS_DRAW);
		Weapons_SetGeomset("geomset 1 1\n");
		pl.fist_mode = HS_FISTS;
		pl.w_attack_next = 1.4f;
		pl.w_idle_next = pl.w_attack_next;
		return;
	}

	if (pl.fist_mode == HS_KNIFE) {
		r  = (float)input_sequence % 5;
		switch (r) {
		case 0:
		case 1:
		case 2:
		case 3:
			Weapons_ViewAnimation(pl, KNIFE_IDLE);
			pl.w_idle_next = 10.0f;
			break;
		default:
			Weapons_ViewAnimation(pl, KNIFE_FIDGET);
			pl.w_idle_next = 2.0f;
		}
	} else {
		r  = (float)input_sequence % 5;
		switch (r) {
		case 0:
		case 1:
		case 2:
			Weapons_ViewAnimation(pl, FISTS_IDLE);
			pl.w_idle_next = 10.0f;
			break;
		case 3:
			Weapons_ViewAnimation(pl, FISTS_FIDGET1);
			pl.w_idle_next = 3.0f;
			break;
		default:
			Weapons_ViewAnimation(pl, FISTS_FIDGET2);
			pl.w_idle_next = 2.333333f;
		}
	}
}

void
w_fists_primary(player pl)
{
	vector src;
	int finalDamage = 0i;

	if (pl.w_attack_next) {
		return;
	}

	Weapons_MakeVectors(pl);
	src = pl.origin + pl.view_ofs;

#ifdef SERVER
	/* make sure we can gib corpses */
	int oldhitcontents = pl.hitcontentsmaski;
	pl.hitcontentsmaski = CONTENTBITS_POINTSOLID | CONTENTBIT_CORPSE;
	traceline(src, src + (v_forward * 32), FALSE, pl);
	pl.hitcontentsmaski = oldhitcontents;
#endif

	pl.a_ammo1 = 1 - pl.a_ammo1;

	if (pl.fist_mode == HS_KNIFE) {
		#ifdef SERVER
		Sound_Play(pl, 8, "weapon_fists.missknife");
		#endif

		if (pl.a_ammo1 == 1) {
			Weapons_ViewAnimation(pl, KNIFE_ATTACK1);
		} else {
			Weapons_ViewAnimation(pl, KNIFE_ATTACK2);
		}
		#ifdef SERVER
		finalDamage = (int)Skill_GetValue("knife1_d", 25);
		#endif
		pl.w_attack_next = 0.5f;
	} else {
		if (pl.a_ammo1 == 1) {
			Weapons_ViewAnimation(pl, FISTS_RIGHT);
			#ifdef SERVER
			Sound_Play(pl, CHAN_WEAPON, "weapon_fists.hitright");
			#endif
		} else {
			Weapons_ViewAnimation(pl, FISTS_LEFT);
			#ifdef SERVER
			Sound_Play(pl, CHAN_WEAPON, "weapon_fists.hitleft");
			#endif
		}
		#ifdef SERVER
		finalDamage = (int)Skill_GetValue("twohandpunch_d", 10);
		#endif
		pl.w_attack_next = 0.25f;
	}
	pl.w_idle_next = pl.w_attack_next;

#ifdef SERVER
	if (trace_fraction >= 1.0) {
		return;
	}

	/* don't bother with decals, we got squibs */
	if (trace_ent.iBleeds) {
		FX_Blood(trace_endpos, [1,0,0]);
	}

	if (trace_ent.takedamage) {
		Damage_Apply(trace_ent, pl, finalDamage, WEAPON_FISTS, DMG_BLUNT);
	} else {
		DecalGroups_Place("Impact.Shot", trace_endpos + (v_forward * -2));
	}
#endif
}

void
w_fists_secondary(player pl)
{

	if (pl.w_attack_next) {
		w_fists_release(pl);
		return;
	}

	if (pl.fist_mode == HS_KNIFE) {
		Weapons_ViewAnimation(pl, KNIFE_HOLSTER);
		pl.fist_mode = HS_KNIFE_TO_FISTS;
		pl.w_attack_next = 0.75f;
		pl.w_idle_next = pl.w_attack_next;
	} else if (pl.fist_mode == HS_FISTS) {
		Weapons_ViewAnimation(pl, FISTS_HOLSTER);
		pl.fist_mode = HS_FISTS_TO_KNIFE;
		pl.w_attack_next = 0.7f;
		pl.w_idle_next = pl.w_attack_next;
	}
}

string
w_fists_wmodel(void)
{
	return "";
}

string
w_fists_pmodel(player pl)
{
/*	if (pl.fist_mode == HS_KNIFE) {
		return "";
	} else {
		return "";
	}*/
	return "";
}

string
w_fists_deathmsg(void)
{
	return "%s killed %s with his knife.";
}

float
w_fists_aimanim(player pl)
{
	return (0);
}

int
w_fists_pickup(player pl, int new, int startammo)
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
w_fists_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	drawpic(
		pos,
		"gfx/vgui/640_weapon_fists0.tga",
		[170,43],
		[1,1,1],
		a,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_fists_precache(void)
{
#ifdef SERVER
	Sound_Precache("weapon_fists.knifedraw");
	Sound_Precache("weapon_fists.hitleft");
	Sound_Precache("weapon_fists.hitright");
	Sound_Precache("weapon_fists.missknife");
#endif

	precache_model("models/v_hands.mdl");
}

weapon_t w_fists =
{
	.name		= "fists",
	.id			= ITEM_FISTS,
	.weight		= WEIGHT_FISTS,
	.slot		= 0,
	.slot_pos	= 0,
	.draw		= w_fists_draw,
	.holster	= w_fists_holster,
	.primary	= w_fists_primary,
	.secondary	= w_fists_secondary,
	.reload		= __NULL__,
	.release	= w_fists_release,
	.postdraw	= __NULL__,
	.precache	= w_fists_precache,
	.pickup		= __NULL__,
	.updateammo	= w_fists_updateammo,
	.wmodel		= __NULL__,
	.pmodel		= __NULL__,
	.deathmsg	= w_fists_deathmsg,
	.aimanim	= w_fists_aimanim,
	.type		= gunman_wpntype_close,
	.hudpic		= w_fists_hudpic
};