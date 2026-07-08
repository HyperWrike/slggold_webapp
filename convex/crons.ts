import { cronJobs } from "convex/server";
import { internal } from "./_generated/api";

const crons = cronJobs();

// Run session purge daily
crons.interval(
  "purge expired sessions",
  { hours: 24 },
  internal.internal.sessions.purgeExpiredSessions,
  {}
);

export default crons;
