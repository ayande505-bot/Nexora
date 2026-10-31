import type { Country } from './countries';

export type EmergencyNumbers = { police:string; fire:string; ambulance:string };

// Reference dataset: countries not listed here use 112 as the general emergency line.
// Separate numbers below follow the country-specific table used for Nexora.
const SPECIAL: Record<string, EmergencyNumbers> = {
  AE:{police:'999',ambulance:'998',fire:'997'}, AR:{police:'101',ambulance:'107',fire:'100'}, AT:{police:'133',ambulance:'144',fire:'122'},
  AU:{police:'000',ambulance:'000',fire:'000'}, BE:{police:'101',ambulance:'100',fire:'100'}, BR:{police:'190',ambulance:'192',fire:'193'},
  CL:{police:'133',ambulance:'131',fire:'132'}, CN:{police:'110',ambulance:'120',fire:'119'}, CO:{police:'123',ambulance:'123',fire:'123'},
  HR:{police:'192',ambulance:'194',fire:'193'}, CZ:{police:'158',ambulance:'155',fire:'150'}, DE:{police:'110',ambulance:'112',fire:'112'},
  EG:{police:'122',ambulance:'123',fire:'180'}, FR:{police:'17',ambulance:'15',fire:'18'}, GH:{police:'191',ambulance:'193',fire:'192'},
  GR:{police:'100',ambulance:'166',fire:'199'}, HU:{police:'107',ambulance:'104',fire:'105'}, IN:{police:'100',ambulance:'108',fire:'101'},
  ID:{police:'110',ambulance:'118',fire:'113'}, IR:{police:'110',ambulance:'115',fire:'125'}, IL:{police:'100',ambulance:'101',fire:'102'},
  IT:{police:'113',ambulance:'118',fire:'115'}, JP:{police:'110',ambulance:'119',fire:'119'}, KE:{police:'999',ambulance:'999',fire:'999'},
  MY:{police:'999',ambulance:'999',fire:'994'}, MA:{police:'19',ambulance:'15',fire:'15'}, NZ:{police:'111',ambulance:'111',fire:'111'},
  NO:{police:'112',ambulance:'113',fire:'110'}, PK:{police:'15',ambulance:'115',fire:'16'}, PE:{police:'105',ambulance:'106',fire:'116'},
  PH:{police:'117',ambulance:'911',fire:'911'}, PL:{police:'997',ambulance:'999',fire:'998'}, RU:{police:'102',ambulance:'103',fire:'101'},
  SA:{police:'999',ambulance:'997',fire:'998'}, SG:{police:'999',ambulance:'995',fire:'995'}, ZA:{police:'10111',ambulance:'10177',fire:'10177'},
  KR:{police:'112',ambulance:'119',fire:'119'}, ES:{police:'091',ambulance:'061',fire:'080'}, CH:{police:'117',ambulance:'144',fire:'118'},
  TZ:{police:'112',ambulance:'114',fire:'114'}, TH:{police:'191',ambulance:'1669',fire:'199'}, TR:{police:'155',ambulance:'112',fire:'110'},
  GB:{police:'999',ambulance:'999',fire:'999'}, VN:{police:'113',ambulance:'115',fire:'114'},
  HT:{police:'114',ambulance:'116',fire:'115'}
};

const GENERAL_911 = new Set(['AI','AG','BS','BZ','BM','VG','CA','KY','CR','CW','DM','DO','EC','SV','FK','GF','GD','GP','GU','GY','HN','MQ','MX','MS','PA','PY','PR','BL','KN','LC','MF','PM','VC','SX','SR','TC','US','VI','UY','VE']);

export function emergencyForCountry(country: Country): EmergencyNumbers {
  // Prefer the country-specific emergency dataset maintained in Nexora.
  // SPECIAL contains verified/common national short codes; the countries table
  // guarantees that every country entry still has a callable fallback.
  if (SPECIAL[country.code]) return SPECIAL[country.code];
  if (GENERAL_911.has(country.code)) return {police:'911',ambulance:'911',fire:'911'};
  return {
    police: country.police || '112',
    fire: country.fire || '112',
    ambulance: country.ambulance || '112'
  };
}

/**
 * Every country in lib/countries.ts has emergency fields, so the UI always
 * has a number to display. For safety, the app should present the number as
 * an informational shortcut and users should follow local emergency guidance.
 * Source/reference: ITU-T E.129 Important Numbers.
 */
