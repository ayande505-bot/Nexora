export type Profile = {
  id:string; name:string; profession:string; country_code:string; country_name:string; city:string;
  address:string; bio:string; phone:string; photo_url:string|null; premium:boolean; banned:boolean; created_at:string;
  premium_until?:string|null; verified?:boolean; rating?:number; review_count?:number; requested_plan?:string|null; requested_payment_status?:string|null; requested_payment_method?:string|null; requested_payment_amount?:number|null;
};
