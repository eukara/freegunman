/*
 * Copyright (c) 2024 Marco Cawthorne <marco@icculus.org>
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

/*!QUAKED entity_digitgod (1.0 0.0 0.0) (-32 -32 -16) (32 32 16)
# OVERVIEW
A digital display of numbers, will optionally trigger its targets when hitting a specified number.

# KEYS
- "targetname" : Name
- "target" : Target when triggered.
- "maxdamage" : Damage to be taken before getting triggered.

# INPUTS
- "AddToCounter" : Increments the counter by N.
- "SetCounter" : Sets the counter to the desired amount.
- "ResetCounter" : Resets the counter, and will make it able to trigger its target again.

# NOTES
The hologram_damage entity is specifically made to communicate to it when it is damaged.

# TRIVIA
This entity was introduced in Gunman Chronicles (2000).
*/
class
entity_digitgod:NSPointTrigger
{
public:
	void entity_digitgod(void);

	virtual void Input(entity, string, string);
	virtual void SpawnKey(string, string);
	virtual void Spawned(void);
	virtual void Respawn(void);

	nonvirtual void AddToCounter(int);
	nonvirtual void SetCounter(int);
	nonvirtual void ResetCounter(void);

private:
	int m_iMaxDamage;
	int m_iDamageCount;
	bool m_bHasFired;

	NSRenderableEntity m_eDigits[3];

	nonvirtual void _UpdateDigits(void);
};

void
entity_digitgod::entity_digitgod(void)
{
	m_bHasFired = false;
	m_iDamageCount = 0i;
	m_iMaxDamage = 500i;
	m_eDigits[0] = m_eDigits[1] = m_eDigits[2] = __NULL__;
}

void
entity_digitgod::SpawnKey(string keyName, string setValue)
{
	switch (keyName) {
	case "maxdamage":
		m_iMaxDamage = ReadInt(setValue);
		break;
	default:
		super::SpawnKey(keyName, setValue);
	}
}

void
entity_digitgod::Spawned(void)
{
	super::Spawned();

	/* allocate our children */
	if (!m_eDigits[0]) {
		m_eDigits[0] = spawn(NSRenderableEntity);
		m_eDigits[1] = spawn(NSRenderableEntity);
		m_eDigits[2] = spawn(NSRenderableEntity);
	}
}

void
entity_digitgod::Input(entity entityActivator, string inputName, string dataField)
{
	switch (inputName) {
	case "AddToCounter":
		AddToCounter(stoi(dataField));
		break;
	case "SetCounter":
		SetCounter(stoi(dataField));
		break;
	case "ResetCounter":
		ResetCounter();
		break;
	default:
		super::Input(entityActivator, inputName, dataField);
	}
}

void
entity_digitgod::_UpdateDigits(void)
{
	int i = m_iDamageCount;
	int d = 2i;

	if (i >= 999) {
		m_eDigits[0].SetSkin(9);
		m_eDigits[1].SetSkin(9);
		m_eDigits[2].SetSkin(9);
	} else if (i > 0) {
		while (i > 0 && d >= 0) {
			m_eDigits[d].SetSkin((float)i % 10.0f);
			i = i / 10;
			d--;
		}
	} else {
		m_eDigits[0].SetSkin(0);
		m_eDigits[1].SetSkin(0);
		m_eDigits[2].SetSkin(0);
	}

	if (m_bHasFired == true) {
		return;
	}

	/* Trigger upon completion */
	if (m_iDamageCount >= m_iMaxDamage) {
		UseTargets(this, TRIG_TOGGLE, 0.0f);
		m_bHasFired = true;
	}
}

void
entity_digitgod::AddToCounter(int newValue)
{
	m_iDamageCount += newValue;
	_UpdateDigits();
}

void
entity_digitgod::SetCounter(int newValue)
{
	m_iDamageCount = newValue;
	_UpdateDigits();
}

void
entity_digitgod::ResetCounter(void)
{
	m_iDamageCount = 0i;
	_UpdateDigits();
	m_bHasFired = false;
}

void
entity_digitgod::Respawn(void)
{
	vector digitDir = GetSpawnAngles();
	vector digitPos = GetSpawnOrigin();

	for (int i = 0i; i < 3; i++) {
		m_eDigits[i].SetModel("models/digits.mdl");
		m_eDigits[i].SetRenderMode(RM_FULLBRIGHT);
		m_eDigits[i].SetAngles(digitDir);
	}

	makevectors(digitDir);
	m_eDigits[0].SetOrigin(digitPos + v_right * 16);
	m_eDigits[1].SetOrigin(digitPos);
	m_eDigits[2].SetOrigin(digitPos + v_right * -16);

	ResetCounter();
}