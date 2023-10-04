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

bool
HLGameRules::IsMultiplayer(void)
{
	return false;
}

void
HLGameRules::LevelDecodeParms(NSClientPlayer pp)
{
	player pl = (player)pp;
	g_landmarkpos[0] = parm1;
	g_landmarkpos[1] = parm2;
	g_landmarkpos[2] = parm3;
	pl.angles[0] = parm4;
	pl.angles[1] = parm5;
	pl.angles[2] = parm6;
	pl.velocity[0] = parm7;
	pl.velocity[1] = parm8;
	pl.velocity[2] = parm9;
	pl.g_items = parm10;
	pl.activeweapon = parm11;
	pl.flags = parm64;

	/*pl.ammo_9mm = parm12;
	pl.ammo_357 = parm13;
	pl.ammo_buckshot = parm14;
	pl.ammo_m203_grenade = parm15;
	pl.ammo_bolt = parm16;
	pl.ammo_rocket = parm17;
	pl.ammo_uranium = parm18;
	pl.ammo_handgrenade = parm19;
	pl.ammo_satchel = parm20;
	pl.ammo_tripmine = parm21;
	pl.ammo_snark = parm22;
	pl.ammo_hornet = parm23;

	pl.glock_mag = parm24;
	pl.mp5_mag = parm25;
	pl.python_mag = parm26;
	pl.shotgun_mag = parm27;
	pl.crossbow_mag = parm28;
	pl.rpg_mag = parm29;
	pl.satchel_chg = parm30;*/

	pl.ammo_battery = parm12; /* beamgun */
	pl.ammo_chem = parm13; /* chemicalgun */
	pl.ammo_rocket = parm14; /* dml / grenades */
	pl.ammo_gauss = parm15; /* gauspistol */
	pl.ammo_minigun = parm16; /* minigun */
	pl.ammo_buckshot = parm17; /* shotgun */

	pl.fist_mode = parm18; /* knife/fists */
	pl.gauss_mode = parm19;
	pl.shotgun_shells = parm20;
	pl.shotgun_spread = parm21;
	
	pl.dml_launch = parm22; /* when fired, when targeted */
	pl.dml_flightpath = parm23; /* guided, homing, spiral */
	pl.dml_detonate = parm24; /* on impact, in proximity, timed, when tripped */
	pl.dml_payload = parm25; /* explosive, cluster */
	pl.chem_acid = parm26;
	pl.chem_neutral = parm27;
	pl.chem_base = parm28;
	pl.chem_pressure = parm29;

	pl.beam_range = parm30; /* TOUCH TAZER, SHORT TAZER, MEDIUM BEAM, LONG BEAM */
	pl.beam_poweracc = parm31; /* LOW HIGHEST, MEDIUM HIGH, HIGH MEDIUM, HIGHEST LOW */
	pl.beam_lightning = parm32; /* BEAM, CHAIN, BALL */
	pl.gren_detonate = parm33; /* when tripped (tripmine = parm24;, timed, on impact */
	pl.gren_payload = parm34; /* cluster, explosive */

	pl.menu_active = parm35;
	pl.dml_state = parm36;

	if (pl.flags & FL_CROUCHING) {
		setsize(pl, VEC_CHULL_MIN, VEC_CHULL_MAX);
	} else {
		setsize(pl, VEC_HULL_MIN, VEC_HULL_MAX);
	}
}

void
HLGameRules::LevelChangeParms(NSClientPlayer pp)
{
	player pl = (player)pp;
	parm1 = g_landmarkpos[0];
	parm2 = g_landmarkpos[1];
	parm3 = g_landmarkpos[2];
	parm4 = pl.angles[0];
	parm5 = pl.angles[1];
	parm6 = pl.angles[2];
	parm7 = pl.velocity[0];
	parm8 = pl.velocity[1];
	parm9 = pl.velocity[2];
	parm64 = pl.flags;
	parm10 = pl.g_items;
	parm11 = pl.activeweapon;

	parm12 = pl.ammo_battery; /* beamgun */
	parm13 = pl.ammo_chem; /* chemicalgun */
	parm14 = pl.ammo_rocket; /* dml / grenades */
	parm15 = pl.ammo_gauss; /* gauspistol */
	parm16 = pl.ammo_minigun; /* minigun */
	parm17 = pl.ammo_buckshot; /* shotgun */

	parm18 = pl.fist_mode; /* knife/fists */
	parm19 = pl.gauss_mode;
	parm20 = pl.shotgun_shells;
	parm21 = pl.shotgun_spread;
	
	parm22 = pl.dml_launch; /* when fired, when targeted */
	parm23 = pl.dml_flightpath; /* guided, homing, spiral */
	parm24 = pl.dml_detonate; /* on impact, in proximity, timed, when tripped */
	parm25 = pl.dml_payload; /* explosive, cluster */
	parm26 = pl.chem_acid;
	parm27 = pl.chem_neutral;
	parm28 = pl.chem_base;
	parm29 = pl.chem_pressure;

	parm30 = pl.beam_range; /* TOUCH TAZER, SHORT TAZER, MEDIUM BEAM, LONG BEAM */
	parm31 = pl.beam_poweracc; /* LOW HIGHEST, MEDIUM HIGH, HIGH MEDIUM, HIGHEST LOW */
	parm32 = pl.beam_lightning; /* BEAM, CHAIN, BALL */
	parm33 = pl.gren_detonate; /* when tripped (tripmine;, timed, on impact */
	parm34 = pl.gren_payload; /* cluster, explosive */

	parm35 = pl.menu_active;
	parm36 = pl.dml_state;
}

void
HLGameRules::LevelNewParms(void)
{
	parm1 = parm2 = parm3 = parm4 = parm5 = parm6 = parm7 =
	parm8 = parm9 = parm10 = parm11 = parm12 = parm13 = parm14 =
	parm15 = parm16 = parm17 = parm18 = parm19 = parm20 = parm21 =
	parm22 = parm23 = parm24 = parm25 = parm26 = parm27 = parm28 =
	parm29 = parm30 = 0;
	parm64 = FL_CLIENT;
}

/* we check what fields have changed over the course of the frame and network
 * only the ones that have actually changed */
void
HLGameRules::PlayerPostFrame(NSClientPlayer pp)
{
}

void
HLGameRules::PlayerConnect(NSClientPlayer pl)
{
	if (Plugin_PlayerConnect(pl) == FALSE)
		bprint(PRINT_HIGH, sprintf("%s connected\n", pl.netname));
}

void
HLGameRules::PlayerDisconnect(NSClientPlayer pl)
{
	bprint(PRINT_HIGH, sprintf("%s disconnected\n", pl.netname));

	/* Make this unusable */
	pl.solid = SOLID_NOT;
	pl.movetype = MOVETYPE_NONE;
	pl.modelindex = 0;
	pl.health = 0;
	pl.takedamage = 0;
	pl.SendFlags = PLAYER_MODELINDEX;
}

void
HLGameRules::PlayerKill(NSClientPlayer pp)
{
	player pl = (player)pp;
	Damage_Apply(pl, pl, pl.health, WEAPON_NONE, DMG_SKIP_ARMOR);
}

void
TriggerFlashlight(NSClient target)
{
	entity oldself = self;
	self = target;
	Flashlight_Toggle();
	self = oldself;
}

bool
HLGameRules::ImpulseCommand(NSClient bp, float num)
{
	switch (num) {
	case 100:
		TriggerFlashlight(bp);
		break;
	default:
		return super::ImpulseCommand(bp, num);
	}

	return true;
}
