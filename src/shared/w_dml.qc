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

/* the rocket launcher */

enum
{
	DML_IDLE, // 2.5f
	DML_FIDGET, // 2.0f
	DML_RELOADBOTH, // 1.6f
	DML_RELOADLEFT, // 1.6f
	DML_RELOADRIGHT, // 1.6f
	DML_FIRE, // 1.222222f
	DML_CUSTOMIZE, // 4.0f
	DML_DRAW // 1.222222f
};

enum
{
	DS_FULL,
	DS_RELOADING
};

enum
{
	DMENU_NONE,
	DMENU_LAUNCH,
	DMENU_FLIGHTPATH,
	DMENU_DETONATE,
	DMENU_PAYLOAD
};

/* customizable states */
enum
{
	LAUNCH_FIRED,
	LAUNCH_TARGETED
};

enum
{
	FLIGHTPATH_GUIDED,
	FLIGHTPATH_HOMING,
	FLIGHTPATH_SPIRAL
} ;

enum
{
	DETONATE_IMPACT,
	DETONATE_PROXIMITY,
	DETONATE_TIMED,
	DETONATE_TRIPPED
};

enum
{
	PAYLOAD_EXPLOSIVE,
	PAYLOAD_CLUSTER
};

/* functions */
void
w_dml_draw(player pl)
{
	pl.menu_active = 0;
	Weapons_SetModel("models/v_dml.mdl");
	Weapons_SetGeomset("geomset 1 1\n");
	Weapons_ViewAnimation(pl, DML_DRAW);
}

void
w_dml_holster(player pl)
{

}

void
w_dml_release(player pl)
{

	if (pl.w_idle_next) {
		return;
	}
	
	if (pl.dml_state == DS_RELOADING) {
		if (pl.ammo_rocket & 1) {
			Weapons_ViewAnimation(pl, DML_RELOADRIGHT);
		} else {
			Weapons_ViewAnimation(pl, DML_RELOADLEFT);
		}
#ifdef SERVER
		Sound_Play(pl, CHAN_WEAPON, "weapon_dml.reload");
#endif
		pl.w_attack_next = 1.6f;
		pl.w_idle_next = pl.w_attack_next;
		pl.dml_state = DS_FULL;
		return;
	}

	int r  = (float)input_sequence % 5;
	switch (r) {
	case 0:
	case 1:
	case 2:
	case 3:
		Weapons_ViewAnimation(pl, DML_IDLE);
		pl.w_idle_next = 10.0f;
		break;
	default:
		Weapons_ViewAnimation(pl, DML_FIDGET);
		pl.w_idle_next = 2.0f;
	}
}

#ifdef SERVER
void
w_dml_firerocket(player pl)
{
	static void w_dml_rocket_impact(entity target, entity source) {
		Damage_Apply(target, source.owner, Skill_GetValue("sk_gaussfast_d", 13), WEAPON_GAUSSPISTOL, DMG_GENERIC);
	}

	NSProjectile ball = spawn(NSProjectile);
	ball.SetModel("models/rocket.mdl");
	ball.SetAngles(self.v_angle);
	ball.SetScale(0.25f);
	ball.SetRenderMode(RM_ADDITIVE);
	ball.SetOwner(pl);


	ball.SetImpact(w_dml_rocket_impact);

	makevectors(pl.v_angle);
	ball.SetOrigin(Weapons_GetCameraPos(pl) + (v_forward * 8));
	ball.SetVelocity(v_forward * 500);
}
#endif

void
w_dml_primary(player pl)
{
	vector src;

	if (pl.gflags & GF_SEMI_TOGGLED)
		return;

	if (pl.menu_active > 0) {
		pl.menu_active = 0;
		pl.gflags |= GF_SEMI_TOGGLED;
		Weapons_ViewAnimation(pl, DML_CUSTOMIZE);
#ifdef SERVER
		Sound_Play(pl, 8, "weapon_dml.customize");
#endif
		pl.w_attack_next = 4.0f;
		pl.w_idle_next = 5.0f;
		return;
	}

	if (pl.ammo_rocket <= 0)
		return;

	if (pl.w_attack_next)
		return;

	if (pl.dml_state == DS_RELOADING) {
		w_dml_release(pl);
		return;
	}

	src = Weapons_GetCameraPos(pl);

#ifdef SERVER
	w_dml_firerocket(pl);
	Sound_Play(pl, CHAN_WEAPON, "weapon_dml.fire");
#endif

	Weapons_ViewAnimation(pl, DML_FIRE);

	pl.ammo_rocket -= 1;
	pl.w_attack_next = 1.222222f;
	pl.w_idle_next = 1.222222f;
	pl.dml_state = DS_RELOADING;
}

void
w_dml_secondary(player pl)
{

	if (pl.gflags & GF_SEMI_TOGGLED) {
		return;
	}

	pl.gflags |= GF_SEMI_TOGGLED;

	if (pl.w_attack_next) {
		return;
	}

	/* activate menu */
	if (pl.menu_active <= 0 || pl.menu_active == DMENU_PAYLOAD) {
		pl.menu_active = 1;
	} else {
		pl.menu_active = bound(DMENU_LAUNCH, pl.menu_active + 1, DMENU_PAYLOAD);
	}
}

void
w_dml_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_rocket, -1);
}

string
w_dml_wmodel(void)
{
	return "models/w_dml.mdl";
}

string
w_dml_pmodel(player pl)
{
	return "models/p_crossbow.mdl";
}

string
w_dml_deathmsg(void)
{
	return "";
}

float
w_dml_aimanim(player pl)
{
	return (0);
}

int
w_dml_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (pl.ammo_rocket < 100) {
		pl.ammo_rocket = bound(0, pl.ammo_rocket + 2, 100);
	} else {
		return (0);
	}
#endif
	return (1);
}

void
w_dml_hud(player pl)
{
#ifdef CLIENT
	static string lmodes[] = {
		"WHEN FIRED",
		"WHEN TARGETED"
	};
	static string fmodes[] = {
		"GUIDED",
		"HOMING",
		"SPIRAL"
	};
	static string dmodes[] = {
		"ON IMPACT",
		"IN PROXIMITY",
		"TIMED",
		"WHEN TRIPPED"
	};
	static string pmodes[] = {
		"EXPLOSIVE",
		"CLUSTER"
	};
	vector pos;
	vector jitter;
	float lerp;
	
	/* laser */
	if (pl.dml_flightpath == FLIGHTPATH_GUIDED) {
	Weapons_MakeVectors(pl);
	vector src = Weapons_GetCameraPos(pl);
	traceline(src, src + (v_forward * 256), FALSE, pl);
	lerp = Math_Lerp(18,6, trace_fraction);
	jitter[0] = (random(0,2) - 2) * (1 - trace_fraction);
	jitter[1] = (random(0,2) - 2) * (1 - trace_fraction);
	pos = (g_hudres / 2) + ([-lerp,-lerp] / 2);
	drawsubpic(
		pos + jitter,
		[lerp,lerp],
		"sprites/laserdot.spr_0.tga",
		[0,0],
		[1.0, 1.0],
		[1,1,1],
		1.0f,
		DRAWFLAG_ADDITIVE
	);
	}

	/* menu */
	if (pl.menu_active > 0) {
		vector col1, col2, col3, col4;
		string txt1, txt2, txt3, txt4;

		col1 = col2 = col3 = col4 = [1,1,1];
		switch (pl.menu_active) {
		case DMENU_LAUNCH:
			col1 = [0,1,0];
			break;
		case DMENU_FLIGHTPATH:
			col2 = [0,1,0];
			break;
		case DMENU_DETONATE:
			col3 = [0,1,0];
			break;
		case DMENU_PAYLOAD:
			col4 = [0,1,0];
			break;
		}

		txt1 = sprintf("LAUNCH: %s", lmodes[pl.dml_launch]);
		txt2 = sprintf("FLIGHTPATH: %s", fmodes[pl.dml_flightpath]);
		txt3 = sprintf("DETONATE: %s", dmodes[pl.dml_detonate]);
		txt4 = sprintf("PAYLOAD: %s", pmodes[pl.dml_payload]);
		pos = g_hudmins + (g_hudres / 2) + [-80,-48];

		drawfont = Font_GetID(FONT_20);
		drawstring(pos, txt1, [20,20], col1, 1.0f,
			DRAWFLAG_ADDITIVE);
		pos[1] += 24;
		drawstring(pos, txt2, [20,20], col2, 1.0f,
			DRAWFLAG_ADDITIVE);
		pos[1] += 24;
		drawstring(pos, txt3, [20,20], col3, 1.0f,
			DRAWFLAG_ADDITIVE);
		pos[1] += 24;
		drawstring(pos, txt4, [20,20], col4, 1.0f,
			DRAWFLAG_ADDITIVE);
		return;
	}

	pos = g_hudmins + (g_hudres / 2) + [-32,-15];
	drawsubpic(
		pos,
		[63,31],
		g_cross_spr,
		[149/256,1/128],
		[63/256, 31/128],
		[1,1,1],
		1.0f,
		DRAWFLAG_NORMAL
	);

	HUD_DrawAmmo2();
#endif
}

void
w_dml_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	drawpic(
		pos,
		"gfx/vgui/640_weapon_dml0.tga",
		[170,43],
		[1,1,1],
		a,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_dml_precache(void)
{
	precache_model("models/v_dml.mdl");
	precache_model("sprites/laserdot.spr");

#ifdef SERVER
	Sound_Precache("weapon_dml.customize");
	Sound_Precache("weapon_dml.fire");
	Sound_Precache("weapon_dml.reload");

	clientstat(42, EV_INTEGER, player::dml_launch);
	clientstat(43, EV_INTEGER, player::dml_flightpath);
	clientstat(44, EV_INTEGER, player::dml_detonate);
	clientstat(45, EV_INTEGER, player::dml_payload);
#endif
}

weapon_t w_dml =
{
	.name		= "dml",
	.id			= ITEM_DML,
	.weight		= WEIGHT_DML,
	.slot		= 3,
	.slot_pos	= 1,
	.draw		= w_dml_draw,
	.holster	= w_dml_holster,
	.primary	= w_dml_primary,
	.secondary	= w_dml_secondary,
	.reload		= __NULL__,
	.release	= w_dml_release,
	.postdraw	= w_dml_hud,
	.precache	= w_dml_precache,
	.pickup		= w_dml_pickup,
	.updateammo	= w_dml_updateammo,
	.wmodel		= w_dml_wmodel,
	.pmodel		= w_dml_pmodel,
	.deathmsg	= w_dml_deathmsg,
	.aimanim	= w_dml_aimanim,
	.type		= gunman_wpntype_ranged,
	.hudpic		= w_dml_hudpic
};

/* entity definitions for pickups */
#ifdef SERVER
void
weapon_dml(void)
{
	Weapons_InitItem(WEAPON_DML);
}
#endif

#ifdef CLIENT
int
w_dml_hudforward(player pl)
{
	if (pl.menu_active <= 0) {
		return (1);
	}

	switch (pl.menu_active) {
	case DMENU_LAUNCH:
		sendevent("w_dml_launch", "i", 1i);
		break;
	case DMENU_FLIGHTPATH:
		sendevent("w_dml_path", "i", 1i);
		break;
	case DMENU_DETONATE:
		sendevent("w_dml_det", "i", 1i);
		break;
	case DMENU_PAYLOAD:
		sendevent("w_dml_pay", "i", 1i);
		break;
	}
	return (0);
}
int
w_dml_hudback(player pl)
{
	if (pl.menu_active <= 0) {
		return (1);
	}
	
	switch (pl.menu_active) {
	case DMENU_LAUNCH:
		sendevent("w_dml_launch", "i", -1i);
		break;
	case DMENU_FLIGHTPATH:
		sendevent("w_dml_path", "i", -1i);
		break;
	case DMENU_DETONATE:
		sendevent("w_dml_det", "i", -1i);
		break;
	case DMENU_PAYLOAD:
		sendevent("w_dml_pay", "i", -1i);
		break;
	}
	return (0);
}
#else
void
CSEv_w_dml_launch_i(int f)
{
	player pl = (player)self;
	pl.dml_launch = bound(0, pl.dml_launch + f, 1);
}

void
CSEv_w_dml_path_i(int f)
{
	player pl = (player)self;
	pl.dml_flightpath = bound(0, pl.dml_flightpath + f, 2);
}
void
CSEv_w_dml_det_i(int f)
{
	player pl = (player)self;
	pl.dml_detonate = bound(0, pl.dml_detonate + f, 3);
}

void
CSEv_w_dml_pay_i(int f)
{
	player pl = (player)self;
	pl.dml_payload = bound(0, pl.dml_payload + f, 1);
}
#endif
