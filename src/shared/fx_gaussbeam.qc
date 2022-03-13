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

#ifdef CLIENT
var string TRAIL_GAUSSPISTOLBEAM;

void FX_GaussBeam(vector, vector, entity);

void
FX_GaussBeam_Init(void)
{
	TRAIL_GAUSSPISTOLBEAM = spriteframe("sprites/gaussbeam2.spr", 0, 0.0f);
}

void
FX_GaussBeam_Parse(void)
{
	vector pos, angle;
	entity eowner;

	pos[0] = readcoord();
	pos[1] = readcoord();
	pos[2] = readcoord();

	angle[0] = readcoord();
	angle[1] = readcoord();
	angle[2] = readcoord();
	
	eowner = findfloat(world, ::entnum, readentitynum());

	FX_GaussBeam(pos, angle, eowner);
}
#endif

#ifdef CLIENT
float foopredraw(void)
{
	vector vecPlayer;
	player pl = (player)self.owner;

	CSQC_UpdateSeat();
	vecPlayer = pSeat->m_vecPredictedOrigin + pSeat->m_ePlayer.view_ofs;

	/* continously update origin */
	makevectors(pl.v_angle);
	self.origin = self.owner.origin + self.owner.view_ofs + (v_right * 6) + (v_up * -6) + (v_forward * 16);

	makevectors(getproperty(VF_CL_VIEWANGLES));
	setproperty(VF_ORIGIN, vecPlayer);
	R_BeginPolygon(TRAIL_GAUSSPISTOLBEAM, 1, 0);
		R_PolygonVertex(self.angles, [0,0], [1,1,1], self.alpha);
		R_PolygonVertex(self.origin, [0,1], [1,1,1], self.alpha);
	R_EndPolygonRibbon(2, [1,0]);
	self.alpha -= clframetime * 5.0f;

	if (self.alpha <= 0.0f)
		remove(self);

	return PREDRAW_NEXT;
}
#endif

void
FX_GaussBeam(vector vecPos, vector vecAngle, entity eOwner)
{
#ifdef SERVER
	WriteByte(MSG_MULTICAST, SVC_CGAMEPACKET);
	WriteByte(MSG_MULTICAST, EV_GAUSSBEAM);
	WriteCoord(MSG_MULTICAST, vecPos[0]); 
	WriteCoord(MSG_MULTICAST, vecPos[1]); 
	WriteCoord(MSG_MULTICAST, vecPos[2]);
	WriteFloat(MSG_MULTICAST, vecAngle[0]); 
	WriteFloat(MSG_MULTICAST, vecAngle[1]); 
	WriteFloat(MSG_MULTICAST, vecAngle[2]);
	WriteEntity(MSG_MULTICAST, eOwner);

	msg_entity = self;
	multicast(vecPos, MULTICAST_PVS);
#else
	vector vecSrc;
	vector vecEndPos;
	vector vecDir;
	vector vecFirstImpact = [0,0,0];

	makevectors(vecAngle);
	vecDir = v_forward;
	vecSrc = vecPos;
	vecEndPos = vecSrc + v_forward * 1024;
	traceline(vecSrc, vecEndPos, FALSE, eOwner);

	entity foo = spawn();
	foo.alpha = 1.0f;
	foo.predraw = foopredraw;
	foo.angles = trace_endpos;
	foo.drawmask = MASK_ENGINE;
	foo.owner = eOwner;
#endif
}

