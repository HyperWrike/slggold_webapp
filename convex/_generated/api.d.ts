/* eslint-disable */
/**
 * Generated `api` utility.
 *
 * THIS CODE IS AUTOMATICALLY GENERATED.
 *
 * To regenerate, run `npx convex dev`.
 * @module
 */

import type * as admin from "../admin.js";
import type * as auth from "../auth.js";
import type * as authActions from "../authActions.js";
import type * as emailService from "../emailService.js";
import type * as enrollments from "../enrollments.js";
import type * as gst from "../gst.js";
import type * as health from "../health.js";
import type * as internal_authHelpers from "../internal/authHelpers.js";
import type * as internal_emailLookup from "../internal/emailLookup.js";
import type * as internal_payments from "../internal/payments.js";
import type * as internal_profiles from "../internal/profiles.js";
import type * as internal_sessions from "../internal/sessions.js";
import type * as internal_sessionsLookup from "../internal/sessionsLookup.js";
import type * as lib_authHelpers from "../lib/authHelpers.js";
import type * as lib_serialize from "../lib/serialize.js";
import type * as metalPrices from "../metalPrices.js";
import type * as notifications from "../notifications.js";
import type * as payments from "../payments.js";
import type * as portfolio from "../portfolio.js";
import type * as schemes from "../schemes.js";
import type * as seed from "../seed.js";
import type * as testEnv from "../testEnv.js";
import type * as transactions from "../transactions.js";

import type {
  ApiFromModules,
  FilterApi,
  FunctionReference,
} from "convex/server";

declare const fullApi: ApiFromModules<{
  admin: typeof admin;
  auth: typeof auth;
  authActions: typeof authActions;
  emailService: typeof emailService;
  enrollments: typeof enrollments;
  gst: typeof gst;
  health: typeof health;
  "internal/authHelpers": typeof internal_authHelpers;
  "internal/emailLookup": typeof internal_emailLookup;
  "internal/payments": typeof internal_payments;
  "internal/profiles": typeof internal_profiles;
  "internal/sessions": typeof internal_sessions;
  "internal/sessionsLookup": typeof internal_sessionsLookup;
  "lib/authHelpers": typeof lib_authHelpers;
  "lib/serialize": typeof lib_serialize;
  metalPrices: typeof metalPrices;
  notifications: typeof notifications;
  payments: typeof payments;
  portfolio: typeof portfolio;
  schemes: typeof schemes;
  seed: typeof seed;
  testEnv: typeof testEnv;
  transactions: typeof transactions;
}>;

/**
 * A utility for referencing Convex functions in your app's public API.
 *
 * Usage:
 * ```js
 * const myFunctionReference = api.myModule.myFunction;
 * ```
 */
export declare const api: FilterApi<
  typeof fullApi,
  FunctionReference<any, "public">
>;

/**
 * A utility for referencing Convex functions in your app's internal API.
 *
 * Usage:
 * ```js
 * const myFunctionReference = internal.myModule.myFunction;
 * ```
 */
export declare const internal: FilterApi<
  typeof fullApi,
  FunctionReference<any, "internal">
>;

export declare const components: {};
