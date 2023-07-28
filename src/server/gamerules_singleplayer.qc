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
HLSingleplayerRules::IsMultiplayer(void)
{
	return false;
}

void
HLSingleplayerRules::PlayerDeath(NSClientPlayer pl)
{
	pl.movetype = MOVETYPE_NONE;
	pl.solid = SOLID_NOT;
	pl.takedamage = DAMAGE_NO;
	pl.gflags &= ~GF_FLASHLIGHT;
	pl.armor = pl.activeweapon = pl.g_items = pl.weapon = 0;
	pl.health = 0;
	Sound_Play(pl, CHAN_AUTO, "player.die");

	if (cvar("coop") == 1) {
		pl.think = PutClientInServer;
		pl.nextthink = time + 4.0f;
	}

	if (pl.health < -50) {
		vector gibDir = vectoangles(pl.origin - g_dmg_eAttacker.origin);
		float gibStrength = g_dmg_iDamage * 2.0f;
		BreakModel_Entity(pl, gibDir, gibStrength);
	}

	/* Let's handle corpses on the clientside */
	entity corpse = spawn();
	setorigin(corpse, pl.origin + [0,0,32]);
	setmodel(corpse, pl.model);
	setsize(corpse, VEC_HULL_MIN, VEC_HULL_MAX);
	corpse.movetype = MOVETYPE_TOSS;
	corpse.solid = SOLID_TRIGGER;
	corpse.modelindex = pl.modelindex;
	corpse.frame = ANIM_DIESIMPLE;
	corpse.angles = pl.angles;
	corpse.velocity = pl.velocity;
}

void
HLSingleplayerRules::PlayerSpawn(NSClientPlayer pl)
{
	pl.classname = "player";
	pl.health = pl.max_health = 100;
	pl.takedamage = DAMAGE_YES;
	pl.SetSolid(SOLID_SLIDEBOX);
	pl.SetMovetype(MOVETYPE_WALK);
	pl.flags = FL_CLIENT;
	pl.viewzoom = 1.0;
	pl.model = "models/player.mdl";


	if (cvar("coop") == 1) {
		string mymodel = infokey(pl, "model");
		if (mymodel) {
			mymodel = sprintf("models/player/%s/%s.mdl", mymodel, mymodel);
			if (whichpack(mymodel)) {
				pl.model = mymodel;
			}
		}
	}

	setmodel(pl, pl.model);

	pl.SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	pl.ClearVelocity();
	pl.gravity = __NULL__;
	pl.SetFrame(1);
	pl.SendFlags = UPDATE_ALL;
	pl.SetInfoKey("*spec", "0");
	pl.SetInfoKey("*dead", "0");
	pl.SetInfoKey("*deaths", ftos(pl.deaths));
	pl.SetPropData("actor_human");
	pl.SetCanBleed(true);

	/* this is where the mods want to deviate */
	entity spot;

	if (startspot != "") {
		dprint(sprintf("^3Gamerules_Spawn^7: Startspot is %s\n", startspot));
		LevelDecodeParms(pl);
		setorigin(pl, Landmark_GetSpot());
	} else {
		LevelNewParms();
		spot = find(world, ::classname, "info_player_start");
		setorigin(pl, spot.origin);
		pl.angles = spot.angles;
	}

	Weapons_RefreshAmmo(pl);
	Client_FixAngle(pl, pl.angles);
} 



bool
HLSingleplayerRules::ImpulseCommand(NSClient bp, float num)
{
	switch (num) {
	case 101:
		player pl = (player)bp;
		pl.health = 100;
		pl.armor = 100;
		Weapons_AddItem(pl, WEAPON_FISTS, -1);
		Weapons_AddItem(pl, WEAPON_GAUSSPISTOL, -1);
		Weapons_AddItem(pl, WEAPON_BEAMGUN, -1);
		Weapons_AddItem(pl, WEAPON_CHEMICALGUN, -1);
		Weapons_AddItem(pl, WEAPON_DML, -1);
		Weapons_AddItem(pl, WEAPON_MINIGUN, -1);
		Weapons_AddItem(pl, WEAPON_AICORE, -1);
		Weapons_AddItem(pl, WEAPON_SHOTGUN, -1);
		Weapons_AddItem(pl, WEAPON_GRENADE, -1);
		break;
	default:
		return super::ImpulseCommand(bp, num);
	}

	return true;
}
