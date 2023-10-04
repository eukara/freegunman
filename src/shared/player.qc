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

#include "../../../valve/src/shared/skeleton.h"

/* all potential SendFlags bits we can possibly send */
enumflags
{
	PLAYER_TOPFRAME = PLAYER_CUSTOMFIELDSTART,
	PLAYER_BOTTOMFRAME,
	PLAYER_AMMO1,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_UNUSED5,
	PLAYER_UNUSED6,
	PLAYER_UNUSED7
};

class player:NSClientPlayer
{
	PREDICTED_INT(anim_top)
	PREDICTED_FLOAT(anim_top_time)
	PREDICTED_FLOAT(anim_top_delay)
	PREDICTED_INT(anim_bottom)
	PREDICTED_FLOAT(anim_bottom_time)

	PREDICTED_INT(ammo_battery) /* beamgun */
	PREDICTED_INT(ammo_chem) /* chemicalgun */
	PREDICTED_INT(ammo_rocket) /* dml / grenades */
	PREDICTED_INT(ammo_gauss) /* gauspistol */
	PREDICTED_INT(ammo_minigun) /* minigun */
	PREDICTED_INT(ammo_buckshot) /* shotgun */

	PREDICTED_INT(fist_mode) /* knife/fists */
	PREDICTED_INT(gauss_mode)
	PREDICTED_INT(shotgun_shells)
	PREDICTED_INT(shotgun_spread)
	
	PREDICTED_INT(dml_launch) /* when fired, when targeted */
	PREDICTED_INT(dml_flightpath) /* guided, homing, spiral */
	PREDICTED_INT(dml_detonate) /* on impact, in proximity, timed, when tripped */
	PREDICTED_INT(dml_payload) /* explosive, cluster */
	PREDICTED_INT(chem_acid)
	PREDICTED_INT(chem_neutral)
	PREDICTED_INT(chem_base)
	PREDICTED_INT(chem_pressure)

	PREDICTED_INT(beam_range) /* TOUCH TAZER, SHORT TAZER, MEDIUM BEAM, LONG BEAM */
	PREDICTED_INT(beam_poweracc) /* LOW HIGHEST, MEDIUM HIGH, HIGH MEDIUM, HIGHEST LOW */
	PREDICTED_INT(beam_lightning) /* BEAM, CHAIN, BALL */
	PREDICTED_INT(gren_detonate) /* when tripped (tripmine), timed, on impact */
	PREDICTED_INT(gren_payload) /* cluster, explosive */

	PREDICTED_INT(menu_active)
	PREDICTED_INT(dml_state)

	virtual void UpdatePlayerAnimation(float);

#ifdef CLIENT
	virtual void UpdatePlayerAttachments(bool);
	virtual void ReceiveEntity(float,float);
	virtual void PredictPreFrame(void);
	virtual void PredictPostFrame(void);
	virtual void UpdateAliveCam(void);
#endif

#ifdef SERVER
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
	virtual void Save(float);
	virtual void Restore(string,string);
#endif
};

void Animation_PlayerUpdate(player); 
void Animation_TimerUpdate(player, float); 

void
player::UpdatePlayerAnimation(float timelength)
{
	/* calculate our skeletal progression */
	Animation_PlayerUpdate(this);
	/* advance animation timers */
	Animation_TimerUpdate(this, timelength);
}

#ifdef CLIENT
void Camera_RunPosBob(vector angles, __inout vector camera_pos);
void Camera_StrafeRoll(__inout vector camera_angle);
void Shake_Update(NSClientPlayer);

void
player::UpdateAliveCam(void)
{
	vector cam_pos = GetEyePos();
	Camera_RunPosBob(view_angles, cam_pos);

	g_view.SetCameraOrigin(cam_pos);
	Camera_StrafeRoll(view_angles);
	g_view.SetCameraAngle(view_angles);

	if (vehicle) {
		NSVehicle veh = (NSVehicle)vehicle;

		if (veh.UpdateView)
			veh.UpdateView();
	} else if (health) {
		if (autocvar_pm_thirdPerson == TRUE) {
			makevectors(view_angles);
			vector vStart = [pSeat->m_vecPredictedOrigin[0], pSeat->m_vecPredictedOrigin[1], pSeat->m_vecPredictedOrigin[2] + 16] + (v_right * 4);
			vector vEnd = vStart + (v_forward * -48) + [0,0,16] + (v_right * 4);
			traceline(vStart, vEnd, FALSE, this);
			g_view.SetCameraOrigin(trace_endpos + (v_forward * 5));
		}
	}

	Shake_Update(this);
	g_view.AddPunchAngle(punchangle);
}

.string oldmodel;
string Weapons_GetPlayermodel(player, int);

void
player::UpdatePlayerAttachments(bool visible)
{
	/* draw the flashlight */
	if (gflags & GF_FLASHLIGHT) {
		vector src;
		vector ang;
		
		if (entnum != player_localentnum) {
			src = origin + view_ofs;
			ang = v_angle;
		} else {
			src = pSeat->m_vecPredictedOrigin + [0,0,-8];
			ang = view_angles;
		}

		makevectors(ang);
		traceline(src, src + (v_forward * 8096), MOVE_NORMAL, this);

		if (serverkeyfloat("*bspversion") == BSPVER_HL) {
			dynamiclight_add(trace_endpos + (v_forward * -2), 128, [1,1,1]);
		} else {
			float p = dynamiclight_add(src, 512, [1,1,1], 0, "textures/flashlight");
			dynamiclight_set(p, LFIELD_ANGLES, ang);
			dynamiclight_set(p, LFIELD_FLAGS, 3);
		}
	}

	/* FIXME: this needs to be incorporated and simplified, now that we can handle it all in-class */
	if (!visible)
		return;

	/* what's the current weapon model supposed to be anyway? */
	p_model.oldmodel = Weapons_GetPlayermodel(this, activeweapon);

	/* we changed weapons, update skeletonindex */
	if (p_model.model != p_model.oldmodel) {
		/* free memory */
		if (p_model.skeletonindex)
			skel_delete(p_model.skeletonindex);

		/* set the new model and mark us updated */
		setmodel(p_model, p_model.oldmodel);
		p_model.model = p_model.oldmodel;
		
		/* set the new skeletonindex */
		p_model.skeletonindex = skel_create(p_model.modelindex);

		/* hack this thing in here FIXME: this should be done when popping in/out of a pvs */
		if (autocvar(cl_himodels, 1, "Use high-quality thisayer models over lower-definition ones"))
			setcustomskin(this, "", "geomset 0 2\n");
		else
			setcustomskin(this, "", "geomset 0 1\n");
	}

	/* follow thisayer at all times */
	setorigin(p_model, origin);
	p_model.angles = angles;
	skel_build(p_model.skeletonindex, p_model, p_model.modelindex,0, 0, -1);

	/* we have to loop through all valid bones of the weapon model and match them
	 * to the thisayer one */
	for (float i = 0; i < g_pbones.length; i++) {
		vector bpos;
		float pbone = gettagindex(this, g_pbones[i]);
		float wbone = gettagindex(p_model, g_pbones[i]);

		/* if the bone doesn't ignore in either skeletal mesh, ignore */
		if (wbone <= 0 || pbone <= 0)
			continue;

		bpos = gettaginfo(this, pbone);
		
		/* the most expensive bit */
		skel_set_bone_world(p_model, wbone, bpos, v_forward, v_right, v_up);
	}
}

void Weapons_AmmoUpdate(entity);

/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float new, float flChanged)
{
	NSClientPlayer::ReceiveEntity(new, flChanged);

	/* animation */
	READENTITY_BYTE(anim_top, PLAYER_TOPFRAME);
	READENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME);
	READENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME);

	READENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME);
	READENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME);

	READENTITY_BYTE(ammo_battery, PLAYER_AMMO1);
	READENTITY_BYTE(ammo_chem, PLAYER_AMMO1);
	READENTITY_BYTE(ammo_rocket, PLAYER_AMMO1);
	READENTITY_BYTE(ammo_gauss, PLAYER_AMMO1);
	READENTITY_BYTE(ammo_minigun, PLAYER_AMMO1);
	READENTITY_BYTE(ammo_buckshot, PLAYER_AMMO1);
	READENTITY_BYTE(fist_mode, PLAYER_AMMO1);
	READENTITY_BYTE(gauss_mode, PLAYER_AMMO1);
	READENTITY_BYTE(shotgun_shells, PLAYER_AMMO1);
	READENTITY_BYTE(shotgun_spread, PLAYER_AMMO1);

	READENTITY_BYTE(dml_launch, PLAYER_AMMO2);
	READENTITY_BYTE(dml_flightpath, PLAYER_AMMO2);
	READENTITY_BYTE(dml_detonate, PLAYER_AMMO2);
	READENTITY_BYTE(dml_payload, PLAYER_AMMO2);
	READENTITY_BYTE(chem_acid, PLAYER_AMMO2);
	READENTITY_BYTE(chem_neutral, PLAYER_AMMO2);
	READENTITY_BYTE(chem_base, PLAYER_AMMO2);
	READENTITY_BYTE(chem_pressure, PLAYER_AMMO2);

	READENTITY_BYTE(beam_range, PLAYER_AMMO3);
	READENTITY_BYTE(beam_poweracc, PLAYER_AMMO3);
	READENTITY_BYTE(beam_lightning, PLAYER_AMMO3);
	READENTITY_BYTE(gren_detonate, PLAYER_AMMO3);
	READENTITY_BYTE(gren_payload, PLAYER_AMMO3);
	READENTITY_BYTE(menu_active, PLAYER_AMMO3);
	READENTITY_BYTE(dml_state, PLAYER_AMMO3);

	if (flChanged & PLAYER_AMMO1 || flChanged & PLAYER_AMMO2 || flChanged & PLAYER_AMMO3)
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
	NSClientPlayer::PredictPreFrame();

	SAVE_STATE(anim_top)
	SAVE_STATE(anim_top_time)
	SAVE_STATE(anim_top_delay)
	SAVE_STATE(anim_bottom)
	SAVE_STATE(anim_bottom_time)

	SAVE_STATE(ammo_battery)
	SAVE_STATE(ammo_chem)
	SAVE_STATE(ammo_rocket)
	SAVE_STATE(ammo_gauss)
	SAVE_STATE(ammo_minigun)
	SAVE_STATE(ammo_buckshot)
	SAVE_STATE(fist_mode)
	SAVE_STATE(gauss_mode)
	SAVE_STATE(shotgun_shells)
	SAVE_STATE(shotgun_spread)

	SAVE_STATE(dml_launch)
	SAVE_STATE(dml_flightpath)
	SAVE_STATE(dml_detonate)
	SAVE_STATE(dml_payload)
	SAVE_STATE(chem_acid)
	SAVE_STATE(chem_neutral)
	SAVE_STATE(chem_base)
	SAVE_STATE(chem_pressure)

	SAVE_STATE(beam_range)
	SAVE_STATE(beam_poweracc)
	SAVE_STATE(beam_lightning)
	SAVE_STATE(gren_detonate)
	SAVE_STATE(gren_payload)

	SAVE_STATE(menu_active)
	SAVE_STATE(dml_state)
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
	NSClientPlayer::PredictPostFrame();

	ROLL_BACK(anim_top)
	ROLL_BACK(anim_top_time)
	ROLL_BACK(anim_top_delay)
	ROLL_BACK(anim_bottom)
	ROLL_BACK(anim_bottom_time)

	ROLL_BACK(ammo_battery)
	ROLL_BACK(ammo_chem)
	ROLL_BACK(ammo_rocket)
	ROLL_BACK(ammo_gauss)
	ROLL_BACK(ammo_minigun)
	ROLL_BACK(ammo_buckshot)
	ROLL_BACK(fist_mode)
	ROLL_BACK(gauss_mode)
	ROLL_BACK(shotgun_shells)
	ROLL_BACK(shotgun_spread)

	ROLL_BACK(dml_launch)
	ROLL_BACK(dml_flightpath)
	ROLL_BACK(dml_detonate)
	ROLL_BACK(dml_payload)
	ROLL_BACK(chem_acid)
	ROLL_BACK(chem_neutral)
	ROLL_BACK(chem_base)
	ROLL_BACK(chem_pressure)

	ROLL_BACK(beam_range)
	ROLL_BACK(beam_poweracc)
	ROLL_BACK(beam_lightning)
	ROLL_BACK(gren_detonate)
	ROLL_BACK(gren_payload)

	ROLL_BACK(menu_active)
	ROLL_BACK(dml_state)
}

#else
void
player::Save(float handle)
{
	super::Save(handle);

	SaveInt(handle, "anim_top", anim_top);
	SaveFloat(handle, "anim_top_time", anim_top_time);
	SaveFloat(handle, "anim_top_delay", anim_top_delay);
	SaveInt(handle, "anim_bottom", anim_bottom);
	SaveFloat(handle, "anim_bottom_time", anim_bottom_time);

	SaveInt(handle, "ammo_battery", ammo_battery); /* beamgun */
	SaveInt(handle, "ammo_chem", ammo_chem); /* chemicalgun */
	SaveInt(handle, "ammo_rocket", ammo_rocket); /* dml / grenades */
	SaveInt(handle, "ammo_gauss", ammo_gauss); /* gauspistol */
	SaveInt(handle, "ammo_minigun", ammo_minigun); /* minigun */
	SaveInt(handle, "ammo_buckshot", ammo_buckshot); /* shotgun */

	SaveInt(handle, "fist_mode", fist_mode); /* knife/fists */
	SaveInt(handle, "gauss_mode", gauss_mode);
	SaveInt(handle, "shotgun_shells", shotgun_shells);
	SaveInt(handle, "shotgun_spread", shotgun_spread);
	
	SaveInt(handle, "dml_launch", dml_launch); /* when fired, when targeted */
	SaveInt(handle, "dml_flightpath", dml_flightpath); /* guided, homing, spiral */
	SaveInt(handle, "dml_detonate", dml_detonate); /* on impact, in proximity, timed, when tripped */
	SaveInt(handle, "dml_payload", dml_payload); /* explosive, cluster */
	SaveInt(handle, "chem_acid", chem_acid);
	SaveInt(handle, "chem_neutral", chem_neutral);
	SaveInt(handle, "chem_base", chem_base);
	SaveInt(handle, "chem_pressure", chem_pressure);

	SaveInt(handle, "beam_range", beam_range); /* TOUCH TAZER, SHORT TAZER, MEDIUM BEAM, LONG BEAM */
	SaveInt(handle, "beam_poweracc", beam_poweracc); /* LOW HIGHEST, MEDIUM HIGH, HIGH MEDIUM, HIGHEST LOW */
	SaveInt(handle, "beam_lightning", beam_lightning); /* BEAM, CHAIN, BALL */
	SaveInt(handle, "gren_detonate", gren_detonate); /* when tripped (tripmine);, timed, on impact */
	SaveInt(handle, "gren_payload", gren_payload); /* cluster, explosive */

	SaveInt(handle, "menu_active", menu_active);
	SaveInt(handle, "dml_state", dml_state);
}

void
player::Restore(string strKey, string strValue)
{
	switch (strKey) {
	case "anim_top":
		anim_top = ReadInt(strValue);
		break;
	case "anim_top_time":
		anim_top_time = ReadFloat(strValue);
		break;
	case "anim_top_delay":
		anim_top_delay = ReadFloat(strValue);
		break;
	case "anim_bottom":
		anim_bottom = ReadInt(strValue);
		break;
	case "anim_bottom_time":
		anim_bottom_time = ReadFloat(strValue);
		break;

	/* AMMO 1 */
	case "ammo_battery":
		ammo_battery = ReadInt(strValue); /* beamgun */
		break;
	case "ammo_chem":
		ammo_chem = ReadInt(strValue); /* chemicalgun */
		break;
	case "ammo_rocket":
		ammo_rocket = ReadInt(strValue); /* dml / grenades */
		break;
	case "ammo_gauss":
		ammo_gauss = ReadInt(strValue); /* gauspistol */
		break;
	case "ammo_minigun":
		ammo_minigun = ReadInt(strValue); /* minigun */
		break;
	case "ammo_buckshot":
		ammo_buckshot = ReadInt(strValue); /* shotgun */
		break;

	case "fist_mode":
		fist_mode = ReadInt(strValue); /* knife/fists */
		break;
	case "gauss_mode":
		gauss_mode = ReadInt(strValue);
		break;
	case "shotgun_shells":
		shotgun_shells = ReadInt(strValue);
		break;
	case "shotgun_spread":
		shotgun_spread = ReadInt(strValue);
		break;
	
	case "dml_launch":
		dml_launch = ReadInt(strValue); /* when fired, when targeted */
		break;
	case "dml_flightpath":
		dml_flightpath = ReadInt(strValue); /* guided, homing, spiral */
		break;
	case "dml_detonate":
		dml_detonate = ReadInt(strValue); /* on impact, in proximity, timed, when tripped */
		break;
	case "dml_payload":
		dml_payload = ReadInt(strValue); /* explosive, cluster */
		break;
	case "chem_acid":
		chem_acid = ReadInt(strValue);
		break;
	case "chem_neutral":
		chem_neutral = ReadInt(strValue);
		break;
	case "chem_base":
		chem_base = ReadInt(strValue);
		break;
	case "chem_pressure":
		chem_pressure = ReadInt(strValue);
		break;

	case "beam_range":
		beam_range = ReadInt(strValue); /* TOUCH TAZER, SHORT TAZER, MEDIUM BEAM, LONG BEAM */
		break;
	case "beam_poweracc":
		beam_poweracc = ReadInt(strValue); /* LOW HIGHEST, MEDIUM HIGH, HIGH MEDIUM, HIGHEST LOW */
		break;
	case "beam_lightning":
		beam_lightning = ReadInt(strValue); /* BEAM, CHAIN, BALL */
		break;
	case "gren_detonate":
		gren_detonate = ReadInt(strValue); /* when tripped (tripmine = ReadInt(strValue);, timed, on impact */
		break;
	case "gren_payload":
		gren_payload = ReadInt(strValue); /* cluster, explosive */
		break;

	case "menu_active":
		menu_active = ReadInt(strValue);
		break;
	case "dml_state":
		dml_state = ReadInt(strValue);
		break;

	default:
		super::Restore(strKey, strValue);
	}
}

void
player::EvaluateEntity(void)
{
	NSClientPlayer::EvaluateEntity();

	EVALUATE_FIELD(anim_top, PLAYER_TOPFRAME);
	EVALUATE_FIELD(anim_top_time, PLAYER_TOPFRAME);
	EVALUATE_FIELD(anim_top_delay, PLAYER_TOPFRAME);

	EVALUATE_FIELD(anim_bottom, PLAYER_BOTTOMFRAME);
	EVALUATE_FIELD(anim_bottom_time, PLAYER_BOTTOMFRAME);

	EVALUATE_FIELD(ammo_battery, PLAYER_AMMO1);
	EVALUATE_FIELD(ammo_chem, PLAYER_AMMO1);
	EVALUATE_FIELD(ammo_rocket, PLAYER_AMMO1);
	EVALUATE_FIELD(ammo_gauss, PLAYER_AMMO1);
	EVALUATE_FIELD(ammo_minigun, PLAYER_AMMO1);
	EVALUATE_FIELD(ammo_buckshot, PLAYER_AMMO1);
	EVALUATE_FIELD(fist_mode, PLAYER_AMMO1);
	EVALUATE_FIELD(gauss_mode, PLAYER_AMMO1);
	EVALUATE_FIELD(shotgun_shells, PLAYER_AMMO1);
	EVALUATE_FIELD(shotgun_spread, PLAYER_AMMO1);

	EVALUATE_FIELD(dml_launch, PLAYER_AMMO2);
	EVALUATE_FIELD(dml_flightpath, PLAYER_AMMO2);
	EVALUATE_FIELD(dml_detonate, PLAYER_AMMO2);
	EVALUATE_FIELD(dml_payload, PLAYER_AMMO2);
	EVALUATE_FIELD(chem_acid, PLAYER_AMMO2);
	EVALUATE_FIELD(chem_neutral, PLAYER_AMMO2);
	EVALUATE_FIELD(chem_base, PLAYER_AMMO2);
	EVALUATE_FIELD(chem_pressure, PLAYER_AMMO2);

	EVALUATE_FIELD(beam_range, PLAYER_AMMO3);
	EVALUATE_FIELD(beam_poweracc, PLAYER_AMMO3);
	EVALUATE_FIELD(beam_lightning, PLAYER_AMMO3);
	EVALUATE_FIELD(gren_detonate, PLAYER_AMMO3);
	EVALUATE_FIELD(gren_payload, PLAYER_AMMO3);
	EVALUATE_FIELD(menu_active, PLAYER_AMMO3);
	EVALUATE_FIELD(dml_state, PLAYER_AMMO3);
}

/*
=================
player::SendEntity
=================
*/
float
player::SendEntity(entity ePEnt, float flChanged)
{
	/* don't broadcast invisible players */
	if (IsFakeSpectator() && ePEnt != this)
		return (0);
	if (!GetModelindex() && ePEnt != this)
		return (0);

	flChanged = OptimiseChangedFlags(ePEnt, flChanged);

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, flChanged);

	/* the generic client attributes */
	NSClientPlayer::SendEntity(ePEnt, flChanged);

	SENDENTITY_BYTE(anim_top, PLAYER_TOPFRAME);
	SENDENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME);
	SENDENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME);

	SENDENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME);
	SENDENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME);

	SENDENTITY_BYTE(ammo_battery, PLAYER_AMMO1);
	SENDENTITY_BYTE(ammo_chem, PLAYER_AMMO1);
	SENDENTITY_BYTE(ammo_rocket, PLAYER_AMMO1);
	SENDENTITY_BYTE(ammo_gauss, PLAYER_AMMO1);
	SENDENTITY_BYTE(ammo_minigun, PLAYER_AMMO1);
	SENDENTITY_BYTE(ammo_buckshot, PLAYER_AMMO1);
	SENDENTITY_BYTE(fist_mode, PLAYER_AMMO1);
	SENDENTITY_BYTE(gauss_mode, PLAYER_AMMO1);
	SENDENTITY_BYTE(shotgun_shells, PLAYER_AMMO1);
	SENDENTITY_BYTE(shotgun_spread, PLAYER_AMMO1);

	SENDENTITY_BYTE(dml_launch, PLAYER_AMMO2);
	SENDENTITY_BYTE(dml_flightpath, PLAYER_AMMO2);
	SENDENTITY_BYTE(dml_detonate, PLAYER_AMMO2);
	SENDENTITY_BYTE(dml_payload, PLAYER_AMMO2);
	SENDENTITY_BYTE(chem_acid, PLAYER_AMMO2);
	SENDENTITY_BYTE(chem_neutral, PLAYER_AMMO2);
	SENDENTITY_BYTE(chem_base, PLAYER_AMMO2);
	SENDENTITY_BYTE(chem_pressure, PLAYER_AMMO2);

	SENDENTITY_BYTE(beam_range, PLAYER_AMMO3);
	SENDENTITY_BYTE(beam_poweracc, PLAYER_AMMO3);
	SENDENTITY_BYTE(beam_lightning, PLAYER_AMMO3);
	SENDENTITY_BYTE(gren_detonate, PLAYER_AMMO3);
	SENDENTITY_BYTE(gren_payload, PLAYER_AMMO3);
	SENDENTITY_BYTE(menu_active, PLAYER_AMMO3);
	SENDENTITY_BYTE(dml_state, PLAYER_AMMO3);

	return (1);
}
#endif
