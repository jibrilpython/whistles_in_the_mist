enum SafeworkingCategory {
  electricTrainStaff('Electric Train Staff', 'Staff & Ticket'),
  tabletInstrument('Tablet Instrument', 'Electric Token'),
  mechanicalKeyToken('Mechanical Key Token', 'Key Token'),
  annettsLockKey("Annett's Lock Key", 'Key Token'),
  permissiveBlockIndicator('Permissive Block Indicator', 'Lock & Block'),
  lockAndBlockMachine('Lock-and-Block Machine', 'Lock & Block'),
  trainOrderTablet('Train Order Tablet', 'Train Order');

  const SafeworkingCategory(this.label, this.systemGroup);
  final String label;
  final String systemGroup;
}

enum ArtisanHallmark {
  ironTrack('IronTrack Signal Works'),
  vanguard('Vanguard Foundry Ltd'),
  sovereign('Sovereign Lever & Block Co'),
  caledon('Caledon Telegraph Apparatus'),
  northmoor('Northmoor Cabin Ironworks'),
  meridian('Meridian Token & Staff Works'),
  westinghouseStyle('Westinghouse Pattern Signal Shop'),
  other('Other / Custom');

  const ArtisanHallmark(this.label);
  final String label;
}

enum LineConfigurationAssignment {
  singleLineAbsolute('Single-Line Absolute'),
  doubleLineBlock('Double-Line Block'),
  junctionInterlocking('Junction Interlocking'),
  bankerEngineTerritory('Banker Engine Territory'),
  tunnelBlockSection('Isolated Tunnel Block'),
  yardLimitRelease('Yard-Limit Release');

  const LineConfigurationAssignment(this.label);
  final String label;
}

enum LockingMechanismConfiguration {
  electromagneticTumbler('Electro-magnetic tumbler lock'),
  mechanicalPinTumbler('Mechanical pin-tumbler'),
  dualLeverSlider('Dual-lever slider'),
  rotativeKeywayBlock('Rotative keyway block'),
  staffPlungerCircuit('Staff plunger circuit'),
  tabletMagazineLatch('Tablet magazine latch');

  const LockingMechanismConfiguration(this.label);
  final String label;
}

enum HousingComposition {
  castIronBrass('Cast iron body with polished brass bezel'),
  teakCabinet('Teak wood case'),
  enamelSteel('Enamel-coated steel'),
  copperDomeOak('Copper-domed oak cabinet'),
  japannedIron('Japanned iron column'),
  brassBoundMahogany('Brass-bound mahogany case');

  const HousingComposition(this.label);
  final String label;
}

enum LineProvenance {
  mountainPass('Forgotten mountain pass branch line'),
  coastalCoal('Abandoned coastal coal route'),
  deepCutTunnel('Historic deep-cut freight tunnel'),
  quarryTramway('Slate quarry tramway exchange point'),
  borderJunction('Borderland junction interlocking cabin'),
  wildernessLoop('Isolated wilderness loop section'),
  other('Other / Unknown');

  const LineProvenance(this.label);
  final String label;
}

enum SafeworkingSystemFilter {
  staffTicket('Staff & Ticket'),
  electricToken('Electric Token'),
  lockBlock('Lock & Block'),
  keyToken('Key Token'),
  trainOrder('Train Order');

  const SafeworkingSystemFilter(this.label);
  final String label;
}

SafeworkingSystemFilter filterForCategory(SafeworkingCategory category) {
  return SafeworkingSystemFilter.values.firstWhere(
    (filter) => filter.label == category.systemGroup,
    orElse: () => SafeworkingSystemFilter.staffTicket,
  );
}
