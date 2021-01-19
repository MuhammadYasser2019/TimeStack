export const isEmpty = value =>
  value === undefined ||
  value === null ||
  value === "" ||
  value === "<div></div>" ||
  (typeof value === "object" && Object.keys(value).length === 0) ||
  (typeof value === "string" && value.trim().length === 0);