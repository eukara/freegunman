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
	AIC_IDLE, // 1.777778f
	AIC_PLUGIN, // 1.066667f
	AIC_DRAW // 1.7f
};

void
w_aicore_draw(player pl)
{
	pl.menu_active = 0;
	Weapons_SetModel("models/v_aicore.mdl");
	Weapons_SetGeomset("geomset 1 1\n");
	Weapons_ViewAnimation(pl, AIC_DRAW);
}

void
w_aicore_holster(player pl)
{
}

void
w_aicore_primary(player pl)
{
	vector src;
	if (pl.w_attack_next) {
		return;
	}

	src = Weapons_GetCameraPos(pl);
	makevectors(pl.v_angle);

	traceline(src, src + v_forward * 96, MOVE_NORMAL, pl);

	if (trace_fraction < 1.0f) {
		if (trace_ent.classname == "button_aiwallplug") {
#ifdef SERVER
			NSEntity wallPlug = (NSEntity)trace_ent;
			wallPlug.Trigger(pl, TRIG_TOGGLE);
#endif
			Weapons_ViewAnimation(pl, AIC_PLUGIN);
			pl.w_attack_next = 5.0;
			pl.w_idle_next = 10.0f;
			return;
		}
	}

	pl.w_attack_next = 0.15f;
	pl.w_idle_next = 2.5f;
}

void
w_aicore_release(player pl)
{

	pl.gflags |= GF_SEMI_TOGGLED;

	if (pl.w_idle_next) {
		return;
	}

	Weapons_ViewAnimation(pl, AIC_IDLE);
	pl.w_idle_next = 1.777778f;
}

void
w_aicore_updateammo(player pl)
{
	
}

string
w_aicore_wmodel(void)
{
	return "";
}

string
w_aicore_pmodel(player pl)
{
	return "models/w_aicore.mdl";
}

string
w_aicore_deathmsg(void)
{
	return "";
}

float
w_aicore_aimanim(player pl)
{
	return (0);
}

void
w_aicore_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	drawpic(
		pos,
		"gfx/vgui/640_weapon_aicore0.tga",
		[170,43],
		[1,1,1],
		a,
		DRAWFLAG_NORMAL
	);
#endif
}

void
w_aicore_precache(void)
{
	precache_model("models/v_aicore.mdl");
}

weapon_t w_aicore =
{
	.name		= "aicore",
	.id			= ITEM_AICORE,
	.weight		= WEIGHT_AICORE,
	.slot		= 0,
	.slot_pos	= 1,
	.draw		= w_aicore_draw,
	.holster	= w_aicore_holster,
	.primary	= w_aicore_primary,
	.secondary	= __NULL__,
	.reload		= __NULL__,
	.release	= w_aicore_release,
	.postdraw	= __NULL__,
	.precache	= w_aicore_precache,
	.pickup		= __NULL__,
	.updateammo	= w_aicore_updateammo,
	.wmodel		= w_aicore_wmodel,
	.pmodel		= w_aicore_pmodel,
	.deathmsg	= w_aicore_deathmsg,
	.aimanim	= w_aicore_aimanim,
	.type		= gunman_wpntype_close,
	.hudpic		= w_aicore_hudpic
};
