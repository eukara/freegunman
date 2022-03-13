/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
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

/* all potential SendFlags bits we can possibly send */
enumflags
{
	PLAYER_KEEPALIVE,
	PLAYER_MODELINDEX,
	PLAYER_ORIGIN,
	PLAYER_ORIGIN_Z,
	PLAYER_ANGLES_X,
	PLAYER_ANGLES_Y,
	PLAYER_COLORMAP,
	PLAYER_VELOCITY,
	PLAYER_VELOCITY_Z,
	PLAYER_FLAGS,
	PLAYER_WEAPON,
	PLAYER_ITEMS,
	PLAYER_HEALTH,
	PLAYER_ARMOR,
	PLAYER_MOVETYPE,
	PLAYER_VIEWOFS,
	PLAYER_TOPFRAME,
	PLAYER_BOTTOMFRAME,
	PLAYER_AMMO1,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_UNUSED1,
	PLAYER_UNUSED2
};

class player:base_player
{
	PREDICTED_INT(anim_top);
	PREDICTED_FLOAT(anim_top_time);
	PREDICTED_FLOAT(anim_top_delay);
	PREDICTED_INT(anim_bottom);
	PREDICTED_FLOAT(anim_bottom_time);

	PREDICTED_INT(ammo_battery); /* beamgun */
	PREDICTED_INT(ammo_chem); /* chemicalgun */
	PREDICTED_INT(ammo_rocket); /* dml / grenades */
	PREDICTED_INT(ammo_gauss); /* gauspistol */
	PREDICTED_INT(ammo_minigun); /* minigun */
	PREDICTED_INT(ammo_buckshot); /* shotgun */
	PREDICTED_INT(fist_mode); /* knife/fists */
	PREDICTED_INT(gauss_mode);
	PREDICTED_INT(shotgun_shells);
	PREDICTED_INT(shotgun_spread);
	
	PREDICTED_INT(dml_launch); /* when fired, when targeted */
	PREDICTED_INT(dml_flightpath); /* guided, homing, spiral */
	PREDICTED_INT(dml_detonate); /* on impact, in proximity, timed, when tripped */
	PREDICTED_INT(dml_payload); /* explosive, cluster */
	PREDICTED_INT(chem_acid);
	PREDICTED_INT(chem_neutral);
	PREDICTED_INT(chem_base);
	PREDICTED_INT(chem_pressure);

	PREDICTED_INT(beam_range); /* TOUCH TAZER, SHORT TAZER, MEDIUM BEAM, LONG BEAM */
	PREDICTED_INT(beam_poweracc); /* LOW HIGHEST, MEDIUM HIGH, HIGH MEDIUM, HIGHEST LOW */
	PREDICTED_INT(beam_lightning); /* BEAM, CHAIN, BALL */
	PREDICTED_INT(gren_detonate); /* when tripped (tripmine), timed, on impact */
	PREDICTED_INT(gren_payload); /* cluster, explosive */

	PREDICTED_INT(menu_active);
	PREDICTED_INT(dml_state);

#ifdef CLIENT
	virtual void(void) draw;
	virtual float() predraw;
	virtual void(void) postdraw;
	virtual void(float,float) ReceiveEntity;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
#else
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
#endif
};

#ifdef CLIENT
void Weapons_AmmoUpdate(entity);
/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float new, float fl)
{
	base_player::ReceiveEntity(new, fl);

	/* animation */
	if (fl & PLAYER_TOPFRAME) {
		anim_top = readbyte();
		anim_top_time = readfloat();
		anim_top_delay = readfloat();
	}
	if (fl & PLAYER_BOTTOMFRAME) {
		anim_bottom = readbyte();
		anim_bottom_time = readfloat();
	}

	if (fl & PLAYER_AMMO1) {
		ammo_battery = readbyte();
		ammo_chem = readbyte();
		ammo_rocket = readbyte();
		ammo_gauss = readbyte();
		ammo_minigun = readbyte();
		ammo_buckshot = readbyte();
		fist_mode = readbyte();
		gauss_mode = readbyte();
		shotgun_shells = readbyte();
		shotgun_spread = readbyte();
	}
	
	if (fl & PLAYER_AMMO2) {
		dml_launch = readbyte();
		dml_flightpath = readbyte();
		dml_detonate = readbyte();
		dml_payload = readbyte();
		chem_acid = readbyte();
		chem_neutral = readbyte();
		chem_base = readbyte();
		chem_pressure = readbyte();
	}

	if (fl & PLAYER_AMMO3) {
		beam_range = readbyte();
		beam_poweracc = readbyte();
		beam_lightning = readbyte();
		gren_detonate = readbyte();
		gren_payload = readbyte();
		menu_active = readbyte();
		dml_state = readbyte();
	}

	if (fl & PLAYER_AMMO1 || fl & PLAYER_AMMO2 || fl & PLAYER_AMMO3)
		Weapons_AmmoUpdate(this);

	setorigin(this, origin);
}

/*
=================
player::PredictPostFrame

Save the last valid server values away in the _net variants of each field
so we can roll them back later.
=================
*/
void
player::PredictPreFrame(void)
{
	base_player::PredictPreFrame();

	SAVE_STATE(anim_top);
	SAVE_STATE(anim_top_time);
	SAVE_STATE(anim_top_delay);
	SAVE_STATE(anim_bottom);
	SAVE_STATE(anim_bottom_time);

	SAVE_STATE(ammo_battery);
	SAVE_STATE(ammo_chem);
	SAVE_STATE(ammo_rocket);
	SAVE_STATE(ammo_gauss);
	SAVE_STATE(ammo_minigun);
	SAVE_STATE(ammo_buckshot);
	SAVE_STATE(fist_mode);
	SAVE_STATE(gauss_mode);
	SAVE_STATE(shotgun_shells);
	SAVE_STATE(shotgun_spread);

	SAVE_STATE(dml_launch);
	SAVE_STATE(dml_flightpath);
	SAVE_STATE(dml_detonate);
	SAVE_STATE(dml_payload);
	SAVE_STATE(chem_acid);
	SAVE_STATE(chem_neutral);
	SAVE_STATE(chem_base);
	SAVE_STATE(chem_pressure);

	SAVE_STATE(beam_range);
	SAVE_STATE(beam_poweracc);
	SAVE_STATE(beam_lightning);
	SAVE_STATE(gren_detonate);
	SAVE_STATE(gren_payload);

	SAVE_STATE(menu_active);
	SAVE_STATE(dml_state);
}

/*
=================
player::PredictPostFrame

Where we roll back our values to the ones last sent/verified by the server.
=================
*/
void
player::PredictPostFrame(void)
{
	base_player::PredictPostFrame();

	ROLL_BACK(anim_top);
	ROLL_BACK(anim_top_time);
	ROLL_BACK(anim_top_delay);
	ROLL_BACK(anim_bottom);
	ROLL_BACK(anim_bottom_time);

	ROLL_BACK(ammo_battery);
	ROLL_BACK(ammo_chem);
	ROLL_BACK(ammo_rocket);
	ROLL_BACK(ammo_gauss);
	ROLL_BACK(ammo_minigun);
	ROLL_BACK(ammo_buckshot);
	ROLL_BACK(fist_mode);
	ROLL_BACK(gauss_mode);
	ROLL_BACK(shotgun_shells);
	ROLL_BACK(shotgun_spread);

	ROLL_BACK(dml_launch);
	ROLL_BACK(dml_flightpath);
	ROLL_BACK(dml_detonate);
	ROLL_BACK(dml_payload);
	ROLL_BACK(chem_acid);
	ROLL_BACK(chem_neutral);
	ROLL_BACK(chem_base);
	ROLL_BACK(chem_pressure);

	ROLL_BACK(beam_range);
	ROLL_BACK(beam_poweracc);
	ROLL_BACK(beam_lightning);
	ROLL_BACK(gren_detonate);
	ROLL_BACK(gren_payload);

	ROLL_BACK(menu_active);
	ROLL_BACK(dml_state);
}

#else
void
player::EvaluateEntity(void)
{
	base_player::EvaluateEntity();

	/* animation */
	if (ATTR_CHANGED(anim_bottom) || ATTR_CHANGED(anim_bottom_time))
		SendFlags |= PLAYER_BOTTOMFRAME;
	if (ATTR_CHANGED(anim_top) || ATTR_CHANGED(anim_top_time) || ATTR_CHANGED(anim_top_delay))
		SendFlags |= PLAYER_TOPFRAME;

	/* ammo 1 type updates */
	if (ATTR_CHANGED(ammo_battery))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(ammo_chem))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(ammo_rocket))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(ammo_gauss))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(ammo_minigun))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(ammo_buckshot))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(fist_mode))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(gauss_mode))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(shotgun_shells))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(shotgun_spread))
		SendFlags |= PLAYER_AMMO1;

	if (ATTR_CHANGED(dml_launch))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(dml_flightpath))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(dml_detonate))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(dml_payload))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(chem_acid))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(chem_neutral))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(chem_base))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(chem_pressure))
		SendFlags |= PLAYER_AMMO2;

	if (ATTR_CHANGED(beam_range))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(beam_poweracc))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(beam_lightning))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(gren_detonate))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(gren_payload))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(menu_active))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(dml_state))
		SendFlags |= PLAYER_AMMO3;

	SAVE_STATE(anim_top);
	SAVE_STATE(anim_top_time);
	SAVE_STATE(anim_top_delay);
	SAVE_STATE(anim_bottom);
	SAVE_STATE(anim_bottom_time);

	SAVE_STATE(ammo_battery);
	SAVE_STATE(ammo_chem);
	SAVE_STATE(ammo_rocket);
	SAVE_STATE(ammo_gauss);
	SAVE_STATE(ammo_minigun);
	SAVE_STATE(ammo_buckshot);
	SAVE_STATE(fist_mode);
	SAVE_STATE(gauss_mode);
	SAVE_STATE(shotgun_shells);
	SAVE_STATE(shotgun_spread);

	SAVE_STATE(dml_launch);
	SAVE_STATE(dml_flightpath);
	SAVE_STATE(dml_detonate);
	SAVE_STATE(dml_payload);
	SAVE_STATE(chem_acid);
	SAVE_STATE(chem_neutral);
	SAVE_STATE(chem_base);
	SAVE_STATE(chem_pressure);

	SAVE_STATE(beam_range);
	SAVE_STATE(beam_poweracc);
	SAVE_STATE(beam_lightning);
	SAVE_STATE(gren_detonate);
	SAVE_STATE(gren_payload);

	SAVE_STATE(menu_active);
	SAVE_STATE(dml_state);
}

/*
=================
player::SendEntity
=================
*/
float
player::SendEntity(entity ePEnt, float fChanged)
{
	if (health <= 0 && ePEnt != this) {
		return (0);
	}

	if (clienttype(ePEnt) != CLIENTTYPE_REAL) {
		return (0);
	}

	if (ePEnt != self) {
		fChanged &= ~PLAYER_ITEMS;
		fChanged &= ~PLAYER_HEALTH;
		fChanged &= ~PLAYER_ARMOR;
		fChanged &= ~PLAYER_VIEWOFS;
		fChanged &= ~PLAYER_AMMO1;
		fChanged &= ~PLAYER_AMMO2;
		fChanged &= ~PLAYER_AMMO3;
	}

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, fChanged);

	base_player::SendEntity(ePEnt, fChanged);

	if (fChanged & PLAYER_TOPFRAME) {
		WriteByte(MSG_ENTITY, anim_top);
		WriteFloat(MSG_ENTITY, anim_top_time);
		WriteFloat(MSG_ENTITY, anim_top_delay);
	}
	if (fChanged & PLAYER_BOTTOMFRAME) {
		WriteByte(MSG_ENTITY, anim_bottom);
		WriteFloat(MSG_ENTITY, anim_bottom_time);
	}

	if (fChanged & PLAYER_AMMO1) {
		WriteByte(MSG_ENTITY, ammo_battery);
		WriteByte(MSG_ENTITY, ammo_chem);
		WriteByte(MSG_ENTITY, ammo_rocket);
		WriteByte(MSG_ENTITY, ammo_gauss);
		WriteByte(MSG_ENTITY, ammo_minigun);
		WriteByte(MSG_ENTITY, ammo_buckshot);
		WriteByte(MSG_ENTITY, fist_mode);
		WriteByte(MSG_ENTITY, gauss_mode);
		WriteByte(MSG_ENTITY, shotgun_shells);
		WriteByte(MSG_ENTITY, shotgun_spread);
	}
	
	if (fChanged & PLAYER_AMMO2) {
		WriteByte(MSG_ENTITY, dml_launch);
		WriteByte(MSG_ENTITY, dml_flightpath);
		WriteByte(MSG_ENTITY, dml_detonate);
		WriteByte(MSG_ENTITY, dml_payload);
		WriteByte(MSG_ENTITY, chem_acid);
		WriteByte(MSG_ENTITY, chem_neutral);
		WriteByte(MSG_ENTITY, chem_base);
		WriteByte(MSG_ENTITY, chem_pressure);
	}

	if (fChanged & PLAYER_AMMO3) {
		WriteByte(MSG_ENTITY, beam_range);
		WriteByte(MSG_ENTITY, beam_poweracc);
		WriteByte(MSG_ENTITY, beam_lightning);
		WriteByte(MSG_ENTITY, gren_detonate);
		WriteByte(MSG_ENTITY, gren_payload);
		WriteByte(MSG_ENTITY, menu_active);
		WriteByte(MSG_ENTITY, dml_state);
	}

	return (1);
}
#endif
