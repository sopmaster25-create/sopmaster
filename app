import React, { useEffect, useMemo, useState } from "react";
import { motion, AnimatePresence } from "framer-motion";
import {
  LayoutGrid,
  FileText,
  Coins,
  Shield,
  Search,
  SlidersHorizontal,
  ArrowUpRight,
  RefreshCcw,
  Download,
  Clock,
  CheckCircle2,
  AlertTriangle,
  GitCommit,
  User,
  Building2,
  Plus,
  ChevronDown,
  Folder,
  Tag,
  History,
  ArrowLeft,
  ExternalLink,
} from "lucide-react";

/**
 * SOPMaster 2.1 — Front-end-only preview
 * 
 * Goals
 * - Tool-first, infrastructural posture (calm, sparse, executive)
 * - Dense operational index (SOPs as assets)
 * - Credits as capacity (quiet, persistent)
 * - Governance surface (versions, events, ownership)
 * - No SOP builder / no backend
 * 
 * Notes
 * - Single-file React preview intended for quick evaluation.
 * - Uses Tailwind classes. If your preview environment doesn't include Tailwind,
 *   replace classes with your CSS system.
 */

// -----------------------------
// Design tokens (practical, not decorative)
// -----------------------------
const TOKENS = {
  bg: "bg-zinc-950",
  panel: "bg-zinc-950",
  surface: "bg-zinc-900/40",
  border: "border-zinc-800/80",
  text: "text-zinc-100",
  text2: "text-zinc-300",
  text3: "text-zinc-400",
  text4: "text-zinc-500",
  accent: "text-zinc-100",
  ring: "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-zinc-200/40 focus-visible:ring-offset-2 focus-visible:ring-offset-zinc-950",
};

// -----------------------------
// Minimal utility components
// -----------------------------
function cx(...classes: Array<string | false | null | undefined>) {
  return classes.filter(Boolean).join(" ");
}

function Badge({ tone = "neutral", children }: { tone?: "neutral" | "ok" | "warn"; children: React.ReactNode }) {
  const styles =
    tone === "ok"
      ? "bg-emerald-500/10 text-emerald-200 border-emerald-500/20"
      : tone === "warn"
        ? "bg-amber-500/10 text-amber-200 border-amber-500/20"
        : "bg-zinc-500/10 text-zinc-200 border-zinc-500/20";
  return (
    <span className={cx("inline-flex items-center gap-1 rounded-full border px-2 py-0.5 text-[11px] leading-5", styles)}>
      {children}
    </span>
  );
}

function Kbd({ children }: { children: React.ReactNode }) {
  return (
    <span className="rounded border border-zinc-700/70 bg-zinc-900/70 px-1.5 py-0.5 text-[11px] text-zinc-300">
      {children}
    </span>
  );
}

function SectionTitle({ title, subtitle, right }: { title: string; subtitle?: string; right?: React.ReactNode }) {
  return (
    <div className="flex items-start justify-between gap-4">
      <div>
        <div className="text-[13px] font-medium text-zinc-100 tracking-wide">{title}</div>
        {subtitle ? <div className="mt-1 text-[12px] text-zinc-400 leading-5">{subtitle}</div> : null}
      </div>
      {right ? <div className="shrink-0">{right}</div> : null}
    </div>
  );
}

function Divider() {
  return <div className="my-4 h-px bg-zinc-800/70" />;
}

function PillButton({
  children,
  onClick,
  icon,
  tone = "default",
  disabled,
}: {
  children: React.ReactNode;
  onClick?: () => void;
  icon?: React.ReactNode;
  tone?: "default" | "primary" | "ghost";
  disabled?: boolean;
}) {
  const base =
    "inline-flex items-center gap-2 rounded-full border px-3 py-1.5 text-[12px] transition-colors disabled:opacity-50 disabled:cursor-not-allowed";
  const styles =
    tone === "primary"
      ? "border-zinc-200/20 bg-zinc-100/10 text-zinc-100 hover:bg-zinc-100/15"
      : tone === "ghost"
        ? "border-transparent bg-transparent text-zinc-300 hover:bg-zinc-900/60 hover:border-zinc-800/70"
        : "border-zinc-800/80 bg-zinc-950/20 text-zinc-200 hover:bg-zinc-900/60";
  return (
    <button type="button" className={cx(base, styles, TOKENS.ring)} onClick={onClick} disabled={disabled}>
      {icon}
      {children}
    </button>
  );
}

function TextButton({
  children,
  onClick,
  icon,
}: {
  children: React.ReactNode;
  onClick?: () => void;
  icon?: React.ReactNode;
}) {
  return (
    <button
      type="button"
      className={cx(
        "inline-flex items-center gap-2 rounded-md px-2 py-1 text-[12px] text-zinc-300 hover:bg-zinc-900/70",
        TOKENS.ring
      )}
      onClick={onClick}
    >
      {icon}
      {children}
    </button>
  );
}

function Input({
  value,
  onChange,
  placeholder,
  left,
}: {
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
  left?: React.ReactNode;
}) {
  return (
    <div className="flex items-center gap-2 rounded-lg border border-zinc-800/80 bg-zinc-950/30 px-3 py-2">
      {left}
      <input
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        className="w-full bg-transparent text-[12px] text-zinc-100 placeholder:text-zinc-500 focus:outline-none"
      />
    </div>
  );
}

function SelectPill({
  label,
  value,
  options,
  onChange,
  icon,
}: {
  label: string;
  value: string;
  options: Array<{ value: string; label: string }>;
  onChange: (v: string) => void;
  icon?: React.ReactNode;
}) {
  return (
    <div className="inline-flex items-center gap-2 rounded-full border border-zinc-800/80 bg-zinc-950/20 px-3 py-1.5">
      {icon}
      <span className="text-[11px] text-zinc-400">{label}</span>
      <span className="text-[12px] text-zinc-200">{options.find((o) => o.value === value)?.label ?? value}</span>
      <ChevronDown className="h-3.5 w-3.5 text-zinc-500" />
      <select
        className="absolute opacity-0 w-0 h-0"
        value={value}
        onChange={(e) => onChange(e.target.value)}
      >
        {options.map((o) => (
          <option key={o.value} value={o.value}>
            {o.label}
          </option>
        ))}
      </select>
    </div>
  );
}

// -----------------------------
// Data model (front-end only)
// -----------------------------
type SOPState = "Active" | "Draft" | "Review" | "Deprecated";

type SOP = {
  id: string;
  title: string;
  domain: "Ecommerce" | "Retail" | "Ops" | "Support" | "Finance";
  owner: string;
  client: string;
  state: SOPState;
  version: string;
  updatedAt: string;
  createdAt: string;
  tags: string[];
};

type VersionEvent = {
  id: string;
  sopId: string;
  at: string;
  actor: string;
  type: "Generated" | "Regenerated" | "Promoted" | "Deprecated" | "Exported";
  notes?: string;
  version: string;
};

function isoDaysAgo(days: number) {
  const d = new Date();
  d.setDate(d.getDate() - days);
  return d.toISOString();
}

function formatDate(iso: string) {
  const d = new Date(iso);
  return d.toLocaleDateString(undefined, { year: "numeric", month: "short", day: "2-digit" });
}

function formatTime(iso: string) {
  const d = new Date(iso);
  return d.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit" });
}

const SAMPLE_SOPS: SOP[] = [
  {
    id: "SOP-4012",
    title: "Order Fulfilment — Same-Day Dispatch",
    domain: "Ecommerce",
    owner: "A. Patel",
    client: "Northbridge D2C",
    state: "Active",
    version: "v3.2",
    updatedAt: isoDaysAgo(2),
    createdAt: isoDaysAgo(45),
    tags: ["warehouse", "dispatch", "cutoff"],
  },
  {
    id: "SOP-3988",
    title: "Returns Handling — 14-Day Policy",
    domain: "Support",
    owner: "J. King",
    client: "Northbridge D2C",
    state: "Review",
    version: "v2.0",
    updatedAt: isoDaysAgo(7),
    createdAt: isoDaysAgo(60),
    tags: ["returns", "refunds", "RMA"],
  },
  {
    id: "SOP-4120",
    title: "Store Opening Checklist — Multi-Location",
    domain: "Retail",
    owner: "S. Ahmed",
    client: "Green & Co",
    state: "Active",
    version: "v1.6",
    updatedAt: isoDaysAgo(1),
    createdAt: isoDaysAgo(18),
    tags: ["opening", "POS", "compliance"],
  },
  {
    id: "SOP-3871",
    title: "Supplier Invoice Approval — 2-Step",
    domain: "Finance",
    owner: "M. Chen",
    client: "Green & Co",
    state: "Draft",
    version: "v0.9",
    updatedAt: isoDaysAgo(0),
    createdAt: isoDaysAgo(4),
    tags: ["AP", "approval", "thresholds"],
  },
  {
    id: "SOP-3699",
    title: "Incident Response — Severity Triage",
    domain: "Ops",
    owner: "R. Walker",
    client: "Hawthorne Group",
    state: "Active",
    version: "v4.1",
    updatedAt: isoDaysAgo(10),
    createdAt: isoDaysAgo(120),
    tags: ["incident", "S1", "escalation"],
  },
  {
    id: "SOP-3550",
    title: "Customer Data Access — DSAR Handling",
    domain: "Ops",
    owner: "E. Brown",
    client: "Hawthorne Group",
    state: "Deprecated",
    version: "v1.3",
    updatedAt: isoDaysAgo(90),
    createdAt: isoDaysAgo(240),
    tags: ["GDPR", "DSAR"],
  },
];

const SAMPLE_EVENTS: VersionEvent[] = [
  {
    id: "EV-9001",
    sopId: "SOP-4012",
    at: isoDaysAgo(2),
    actor: "A. Patel",
    type: "Regenerated",
    version: "v3.2",
    notes: "Aligned packing steps with new courier cutoff.",
  },
  {
    id: "EV-9002",
    sopId: "SOP-4012",
    at: isoDaysAgo(14),
    actor: "A. Patel",
    type: "Promoted",
    version: "v3.1",
    notes: "Moved to Active after QA pass.",
  },
  {
    id: "EV-9010",
    sopId: "SOP-3988",
    at: isoDaysAgo(7),
    actor: "J. King",
    type: "Generated",
    version: "v2.0",
    notes: "Initial version for 14-day policy.",
  },
  {
    id: "EV-9020",
    sopId: "SOP-4120",
    at: isoDaysAgo(1),
    actor: "S. Ahmed",
    type: "Regenerated",
    version: "v1.6",
    notes: "Updated safety checks for new insurance requirements.",
  },
  {
    id: "EV-9025",
    sopId: "SOP-3871",
    at: isoDaysAgo(0),
    actor: "M. Chen",
    type: "Generated",
    version: "v0.9",
    notes: "Draft created; pending thresholds.",
  },
  {
    id: "EV-9041",
    sopId: "SOP-3699",
    at: isoDaysAgo(10),
    actor: "R. Walker",
    type: "Regenerated",
    version: "v4.1",
    notes: "Refined escalation routing.",
  },
  {
    id: "EV-9100",
    sopId: "SOP-3550",
    at: isoDaysAgo(90),
    actor: "E. Brown",
    type: "Deprecated",
    version: "v1.3",
    notes: "Replaced by updated DSAR workflow.",
  },
];

// -----------------------------
// SOPDownloader (export surface)
// -----------------------------
/**
 * This is intentionally a front-end-only export surface.
 * It mimics export controls without implementing backend generation.
 * 
 * Replace stubs with your actual implementation when wiring real SOP content.
 */
function SOPDownloader({
  sopId,
  sopTitle,
}: {
  sopId: string;
  sopTitle: string;
}) {
  const formats = [
    { key: "pdf", label: "PDF" },
    { key: "docx", label: "Word" },
    { key: "gdoc", label: "Google Docs" },
    { key: "html", label: "HTML" },
    { key: "txt", label: "TXT" },
  ] as const;

  function fakeExport(fmt: string) {
    // Front-end only: demonstrate the posture and surface.
    // In production: call your export endpoint or generate client-side.
    const msg = `Export queued (front-end preview): ${sopId} — ${fmt.toUpperCase()}`;
    // eslint-disable-next-line no-alert
    alert(msg);
  }

  return (
    <div className="rounded-xl border border-zinc-800/80 bg-zinc-950/20 p-3">
      <div className="flex items-start justify-between gap-3">
        <div>
          <div className="text-[12px] text-zinc-200">Export</div>
          <div className="mt-1 text-[11px] text-zinc-500 leading-5">
            {sopTitle}. No backend wired in this preview.
          </div>
        </div>
        <Download className="h-4 w-4 text-zinc-500" />
      </div>
      <div className="mt-3 flex flex-wrap gap-2">
        {formats.map((f) => (
          <button
            key={f.key}
            type="button"
            className={cx(
              "rounded-full border border-zinc-800/80 bg-zinc-950/30 px-3 py-1.5 text-[12px] text-zinc-200 hover:bg-zinc-900/60",
              TOKENS.ring
            )}
            onClick={() => fakeExport(f.key)}
          >
            {f.label}
          </button>
        ))}
      </div>
    </div>
  );
}

// -----------------------------
// App shell + navigation
// -----------------------------
type Route =
  | { key: "home" }
  | { key: "pricing" }
  | { key: "dashboard" }
  | { key: "workspace"; sopId: string }
  | { key: "credits" }
  | { key: "governance" };

function NavItem({
  active,
  icon,
  label,
  onClick,
  badge,
}: {
  active: boolean;
  icon: React.ReactNode;
  label: string;
  onClick: () => void;
  badge?: React.ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={cx(
        "group flex w-full items-center justify-between rounded-lg border px-3 py-2 text-left text-[12px] transition-colors",
        active
          ? "border-zinc-200/15 bg-zinc-100/5 text-zinc-100"
          : "border-transparent bg-transparent text-zinc-300 hover:bg-zinc-900/70 hover:border-zinc-800/70",
        TOKENS.ring
      )}
    >
      <span className="inline-flex items-center gap-2">
        <span className={cx("opacity-80", active && "opacity-100")}>{icon}</span>
        <span className={cx("tracking-wide", active ? "text-zinc-100" : "text-zinc-300")}>{label}</span>
      </span>
      {badge ? <span className="opacity-90">{badge}</span> : null}
    </button>
  );
}

function CapacityInline({
  credits,
  includedAllocation,
}: {
  credits: number;
  includedAllocation: number;
}) {
  return (
    <div className="rounded-xl border border-zinc-800/80 bg-zinc-950/20 p-3">
      <div className="flex items-start justify-between gap-3">
        <div>
          <div className="text-[11px] text-zinc-500">Capacity</div>
          <div className="mt-1 flex items-baseline gap-2">
            <div className="text-[18px] font-medium text-zinc-100 tabular-nums">{credits}</div>
            <div className="text-[12px] text-zinc-400">credits available</div>
          </div>
          <div className="mt-1 text-[11px] text-zinc-500 leading-5">
            Editing is free. Credits are consumed on generation/regeneration.
          </div>
        </div>
        <div className="rounded-lg border border-zinc-800/80 bg-zinc-950/30 px-2 py-1">
          <div className="text-[10px] text-zinc-500">Included</div>
          <div className="text-[12px] text-zinc-200 tabular-nums">{includedAllocation} allocation</div>
        </div>
      </div>
    </div>
  );
}

function Topbar({
  route,
  onNavigate,
  credits,
}: {
  route: Route;
  onNavigate: (r: Route) => void;
  credits: number;
}) {
  const title =
    route.key === "dashboard"
      ? "Operational Index"
      : route.key === "workspace"
        ? "SOP Workspace"
        : route.key === "credits"
          ? "Credits & Capacity"
          : "Governance";

  const subtitle =
    route.key === "dashboard"
      ? "SOPs as governed assets. Search, filter, and operate at volume."
      : route.key === "workspace"
        ? "Structured deliverable surface. Regenerate and export without noise."
        : route.key === "credits"
          ? "Capacity extends throughput. Credits are work units, not features."
          : "Version events, ownership, and state transitions.";

  return (
    <div className="sticky top-0 z-20 border-b border-zinc-800/70 bg-zinc-950/75 backdrop-blur">
      <div className="mx-auto flex max-w-[1400px] items-center justify-between gap-4 px-4 py-3">
        <div>
          <div className="text-[13px] font-medium text-zinc-100 tracking-wide">{title}</div>
          <div className="mt-1 text-[12px] text-zinc-500 leading-5">{subtitle}</div>
        </div>
        <div className="flex items-center gap-2">
          <div className="hidden md:flex items-center gap-2 rounded-full border border-zinc-800/80 bg-zinc-950/30 px-3 py-1.5">
            <Coins className="h-4 w-4 text-zinc-500" />
            <span className="text-[12px] text-zinc-300">{credits}</span>
            <span className="text-[11px] text-zinc-500">credits</span>
          </div>
          <PillButton
            tone="ghost"
            icon={<ExternalLink className="h-4 w-4" />}
            onClick={() => {
              // Front-end-only placeholder
              alert("Workspace is front-end only in this preview.");
            }}
          >
            System
          </PillButton>
          {route.key === "workspace" ? (
            <PillButton
              tone="default"
              icon={<ArrowLeft className="h-4 w-4" />}
              onClick={() => onNavigate({ key: "dashboard" })}
            >
              Back
            </PillButton>
          ) : null}
        </div>
      </div>
    </div>
  );
}

// -----------------------------
// Dashboard: Operational Index
// -----------------------------
function stateTone(s: SOPState): "neutral" | "ok" | "warn" {
  if (s === "Active") return "ok";
  if (s === "Review" || s === "Draft") return "warn";
  return "neutral";
}

function Dashboard({
  sops,
  onOpen,
  credits,
  includedAllocation,
}: {
  sops: SOP[];
  onOpen: (id: string) => void;
  credits: number;
  includedAllocation: number;
}) {
  const [q, setQ] = useState("");
  const [state, setState] = useState<string>("all");
  const [domain, setDomain] = useState<string>("all");
  const [client, setClient] = useState<string>("all");
  const [sort, setSort] = useState<string>("updated_desc");

  const clients = useMemo(() => Array.from(new Set(sops.map((s) => s.client))).sort(), [sops]);

  const filtered = useMemo(() => {
    const needle = q.trim().toLowerCase();
    let rows = sops.slice();

    if (needle) {
      rows = rows.filter(
        (s) =>
          s.title.toLowerCase().includes(needle) ||
          s.id.toLowerCase().includes(needle) ||
          s.owner.toLowerCase().includes(needle) ||
          s.tags.join(" ").toLowerCase().includes(needle)
      );
    }

    if (state !== "all") rows = rows.filter((s) => s.state === state);
    if (domain !== "all") rows = rows.filter((s) => s.domain === domain);
    if (client !== "all") rows = rows.filter((s) => s.client === client);

    const byUpdated = (a: SOP, b: SOP) => new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime();
    const byCreated = (a: SOP, b: SOP) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime();
    const byTitle = (a: SOP, b: SOP) => a.title.localeCompare(b.title);

    if (sort === "updated_desc") rows.sort(byUpdated);
    if (sort === "created_desc") rows.sort(byCreated);
    if (sort === "title_asc") rows.sort(byTitle);

    return rows;
  }, [sops, q, state, domain, client, sort]);

  const counts = useMemo(() => {
    const c = { Active: 0, Draft: 0, Review: 0, Deprecated: 0 } as Record<SOPState, number>;
    for (const s of sops) c[s.state]++;
    return c;
  }, [sops]);

  return (
    <div className="mx-auto grid max-w-[1400px] grid-cols-12 gap-4 px-4 py-5">
      {/* Left: Index */}
      <div className="col-span-12 xl:col-span-9">
        <div className="rounded-2xl border border-zinc-800/80 bg-zinc-950/20 p-4">
          <SectionTitle
            title="SOP Index"
            subtitle="Search and operate. SOPs are governed assets with state, ownership, and version lineage."
            right={
              <div className="flex items-center gap-2">
                <PillButton
                  tone="default"
                  icon={<Plus className="h-4 w-4" />}
                  onClick={() => alert("Generation is not wired in this preview. This is front-end only.")}
                >
                  New SOP
                </PillButton>
                <PillButton
                  tone="ghost"
                  icon={<ArrowUpRight className="h-4 w-4" />}
                  onClick={() => alert("Bulk actions are intentionally minimal in this preview.")}
                >
                  Actions
                </PillButton>
              </div>
            }
          />

          <div className="mt-4 grid grid-cols-12 gap-3">
            <div className="col-span-12 lg:col-span-6">
              <Input value={q} onChange={setQ} placeholder="Search by ID, title, owner, tag" left={<Search className="h-4 w-4 text-zinc-500" />} />
            </div>
            <div className="col-span-12 lg:col-span-6 flex flex-wrap items-center gap-2">
              <div className="inline-flex items-center gap-2 text-[11px] text-zinc-500">
                <SlidersHorizontal className="h-4 w-4" />
                <span>Filters</span>
              </div>
              <SelectPill
                label="State"
                value={state}
                onChange={setState}
                icon={<Tag className="h-3.5 w-3.5 text-zinc-500" />}
                options={[
                  { value: "all", label: "All" },
                  { value: "Active", label: `Active (${counts.Active})` },
                  { value: "Review", label: `Review (${counts.Review})` },
                  { value: "Draft", label: `Draft (${counts.Draft})` },
                  { value: "Deprecated", label: `Deprecated (${counts.Deprecated})` },
                ]}
              />
              <SelectPill
                label="Domain"
                value={domain}
                onChange={setDomain}
                icon={<Folder className="h-3.5 w-3.5 text-zinc-500" />}
                options={[
                  { value: "all", label: "All" },
                  { value: "Ecommerce", label: "Ecommerce" },
                  { value: "Retail", label: "Retail" },
                  { value: "Ops", label: "Ops" },
                  { value: "Support", label: "Support" },
                  { value: "Finance", label: "Finance" },
                ]}
              />
              <SelectPill
                label="Client"
                value={client}
                onChange={setClient}
                icon={<Building2 className="h-3.5 w-3.5 text-zinc-500" />}
                options={[{ value: "all", label: "All" }, ...clients.map((c) => ({ value: c, label: c }))]}
              />
              <SelectPill
                label="Sort"
                value={sort}
                onChange={setSort}
                icon={<Clock className="h-3.5 w-3.5 text-zinc-500" />}
                options={[
                  { value: "updated_desc", label: "Updated (newest)" },
                  { value: "created_desc", label: "Created (newest)" },
                  { value: "title_asc", label: "Title (A–Z)" },
                ]}
              />
            </div>
          </div>

          <div className="mt-4 overflow-hidden rounded-xl border border-zinc-800/80">
            <div className="grid grid-cols-12 bg-zinc-950/30 px-3 py-2 text-[11px] text-zinc-500">
              <div className="col-span-2">ID</div>
              <div className="col-span-5">Title</div>
              <div className="col-span-2">State</div>
              <div className="col-span-2">Updated</div>
              <div className="col-span-1 text-right">Version</div>
            </div>
            <div className="divide-y divide-zinc-800/70">
              {filtered.map((s) => (
                <button
                  key={s.id}
                  type="button"
                  onClick={() => onOpen(s.id)}
                  className={cx(
                    "grid w-full grid-cols-12 px-3 py-3 text-left transition-colors hover:bg-zinc-900/40",
                    TOKENS.ring
                  )}
                >
                  <div className="col-span-2">
                    <div className="text-[12px] text-zinc-200 tabular-nums">{s.id}</div>
                    <div className="mt-1 text-[11px] text-zinc-500">{s.domain}</div>
                  </div>
                  <div className="col-span-5">
                    <div className="text-[12px] text-zinc-100 leading-5">{s.title}</div>
                    <div className="mt-1 flex flex-wrap items-center gap-2 text-[11px] text-zinc-500">
                      <span className="inline-flex items-center gap-1"><User className="h-3.5 w-3.5" />{s.owner}</span>
                      <span className="text-zinc-700">•</span>
                      <span className="inline-flex items-center gap-1"><Building2 className="h-3.5 w-3.5" />{s.client}</span>
                      <span className="text-zinc-700">•</span>
                      <span className="inline-flex items-center gap-1"><Tag className="h-3.5 w-3.5" />{s.tags[0]}</span>
                      {s.tags.length > 1 ? <span className="text-zinc-600">+{s.tags.length - 1}</span> : null}
                    </div>
                  </div>
                  <div className="col-span-2 flex items-center">
                    <Badge tone={stateTone(s.state)}>
                      {s.state === "Active" ? <CheckCircle2 className="h-3.5 w-3.5" /> : null}
                      {s.state === "Review" || s.state === "Draft" ? <AlertTriangle className="h-3.5 w-3.5" /> : null}
                      {s.state}
                    </Badge>
                  </div>
                  <div className="col-span-2">
                    <div className="text-[12px] text-zinc-200 tabular-nums">{formatDate(s.updatedAt)}</div>
                    <div className="mt-1 text-[11px] text-zinc-500 tabular-nums">{formatTime(s.updatedAt)}</div>
                  </div>
                  <div className="col-span-1 text-right">
                    <div className="text-[12px] text-zinc-200 tabular-nums">{s.version}</div>
                    <div className="mt-1 text-[11px] text-zinc-500">Open</div>
                  </div>
                </button>
              ))}
            </div>
          </div>

          <div className="mt-3 flex items-center justify-between text-[11px] text-zinc-500">
            <div>
              <span className="text-zinc-300 tabular-nums">{filtered.length}</span> results
              {q.trim() ? (
                <>
                  <span className="text-zinc-700"> • </span>
                  <span>Query: </span>
                  <span className="text-zinc-300">“{q.trim()}”</span>
                </>
              ) : null}
            </div>
            <div className="hidden md:flex items-center gap-2">
              <span>Keyboard</span>
              <Kbd>/</Kbd>
              <span>search</span>
              <span className="text-zinc-700">•</span>
              <Kbd>↵</Kbd>
              <span>open</span>
            </div>
          </div>
        </div>
      </div>

      {/* Right: Operational side panel */}
      <div className="col-span-12 xl:col-span-3 space-y-4">
        <CapacityInline credits={credits} includedAllocation={includedAllocation} />

        <div className="rounded-2xl border border-zinc-800/80 bg-zinc-950/20 p-4">
          <SectionTitle
            title="System Posture"
            subtitle="Infrastructure behaviour. Quiet defaults. Competent-user assumption."
          />
          <Divider />
          <ul className="space-y-3 text-[12px] text-zinc-400 leading-5">
            <li className="flex gap-3">
              <span className="mt-0.5 h-1.5 w-1.5 rounded-full bg-zinc-600" />
              <span>
                Credits represent throughput capacity. They are consumed only on generation/regeneration.
              </span>
            </li>
            <li className="flex gap-3">
              <span className="mt-0.5 h-1.5 w-1.5 rounded-full bg-zinc-600" />
              <span>
                SOPs are versioned assets with ownership, state, and governance events.
              </span>
            </li>
            <li className="flex gap-3">
              <span className="mt-0.5 h-1.5 w-1.5 rounded-full bg-zinc-600" />
              <span>
                Minimal coaching. No onboarding tours. The UI stays out of the way.
              </span>
            </li>
          </ul>
        </div>

        <div className="rounded-2xl border border-zinc-800/80 bg-zinc-950/20 p-4">
          <SectionTitle title="Signals" subtitle="These are the only signals that matter." />
          <Divider />
          <div className="space-y-2">
            <div className="flex items-center justify-between text-[12px]">
              <span className="text-zinc-500">Active SOPs</span>
              <span className="text-zinc-200 tabular-nums">{counts.Active}</span>
            </div>
            <div className="flex items-center justify-between text-[12px]">
              <span className="text-zinc-500">In review</span>
              <span className="text-zinc-200 tabular-nums">{counts.Review}</span>
            </div>
            <div className="flex items-center justify-between text-[12px]">
              <span className="text-zinc-500">Drafts</span>
              <span className="text-zinc-200 tabular-nums">{counts.Draft}</span>
            </div>
            <div className="flex items-center justify-between text-[12px]">
              <span className="text-zinc-500">Deprecated</span>
              <span className="text-zinc-200 tabular-nums">{counts.Deprecated}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// -----------------------------
// Workspace: SOP surface (no builder)
// -----------------------------
function SOPWorkspace({
  sop,
  events,
  credits,
  onConsumeCredit,
  onBack,
}: {
  sop: SOP;
  events: VersionEvent[];
  credits: number;
  onConsumeCredit: () => void;
  onBack: () => void;
}) {
  const [activeTab, setActiveTab] = useState<"deliverable" | "governance">("deliverable");

  const sopEvents = useMemo(
    () => events.filter((e) => e.sopId === sop.id).sort((a, b) => new Date(b.at).getTime() - new Date(a.at).getTime()),
    [events, sop.id]
  );

  return (
    <div className="mx-auto grid max-w-[1400px] grid-cols-12 gap-4 px-4 py-5">
      <div className="col-span-12 xl:col-span-8">
        <div className="rounded-2xl border border-zinc-800/80 bg-zinc-950/20 p-4">
          <div className="flex items-start justify-between gap-4">
            <div>
              <div className="text-[11px] text-zinc-500">{sop.id}</div>
              <div className="mt-1 text-[16px] font-medium text-zinc-100 tracking-wide">{sop.title}</div>
              <div className="mt-2 flex flex-wrap items-center gap-2 text-[11px] text-zinc-500">
                <span className="inline-flex items-center gap-1"><Building2 className="h-3.5 w-3.5" />{sop.client}</span>
                <span className="text-zinc-700">•</span>
                <span className="inline-flex items-center gap-1"><User className="h-3.5 w-3.5" />{sop.owner}</span>
                <span className="text-zinc-700">•</span>
                <span className="inline-flex items-center gap-1"><GitCommit className="h-3.5 w-3.5" />{sop.version}</span>
                <span className="text-zinc-700">•</span>
                <Badge tone={stateTone(sop.state)}>{sop.state}</Badge>
              </div>
            </div>
            <div className="flex items-center gap-2">
              <TextButton icon={<ArrowLeft className="h-4 w-4" />} onClick={onBack}>
                Index
              </TextButton>
              <PillButton
                tone="default"
                icon={<RefreshCcw className="h-4 w-4" />}
                disabled={credits <= 0}
                onClick={() => {
                  onConsumeCredit();
                  alert("Regeneration is front-end only in this preview. Credit consumed to demonstrate capacity mechanics.");
                }}
              >
                Regenerate
              </PillButton>
            </div>
          </div>

          <Divider />

          <div className="flex items-center gap-2">
            <PillButton tone={activeTab === "deliverable" ? "primary" : "default"} onClick={() => setActiveTab("deliverable")}>
              Deliverable
            </PillButton>
            <PillButton tone={activeTab === "governance" ? "primary" : "default"} onClick={() => setActiveTab("governance")}>
              Governance
            </PillButton>
            <div className="ml-auto text-[11px] text-zinc-500">
              Updated {formatDate(sop.updatedAt)} at {formatTime(sop.updatedAt)}
            </div>
          </div>

          <div className="mt-4">
            <AnimatePresence mode="wait">
              {activeTab === "deliverable" ? (
                <motion.div
                  key="deliverable"
                  initial={{ opacity: 0, y: 6 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -6 }}
                  transition={{ duration: 0.16 }}
                >
                  <DeliverableSurface sop={sop} />
                </motion.div>
              ) : (
                <motion.div
                  key="gov"
                  initial={{ opacity: 0, y: 6 }}
                  animate={{ opacity: 1, y: 0 }}
                  exit={{ opacity: 0, y: -6 }}
                  transition={{ duration: 0.16 }}
                >
                  <GovernancePanelCompact events={sopEvents} />
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        </div>
      </div>

      <div className="col-span-12 xl:col-span-4 space-y-4">
        <div className="rounded-2xl border border-zinc-800/80 bg-zinc-950/20 p-4">
          <SectionTitle
            title="Operational Controls"
            subtitle="Quiet controls. No coaching. Everything maps to governance or throughput."
          />
          <Divider />
          <div className="grid grid-cols-2 gap-2">
            <PillButton
              tone="default"
              icon={<Shield className="h-4 w-4" />}
              onClick={() => alert("State transitions are front-end only in this preview.")}
            >
              Promote
            </PillButton>
            <PillButton
              tone="default"
              icon={<AlertTriangle className="h-4 w-4" />}
              onClick={() => alert("Deprecation is front-end only in this preview.")}
            >
              Deprecate
            </PillButton>
            <PillButton
              tone="default"
              icon={<History className="h-4 w-4" />}
              onClick={() => alert("Audit trail is visible in Governance tab.")}
            >
              Audit
            </PillButton>
            <PillButton
              tone="default"
              icon={<ArrowUpRight className="h-4 w-4" />}
              onClick={() => alert("Publishing is not wired in this preview.")}
            >
              Deploy
            </PillButton>
          </div>
        </div>

        <SOPDownloader sopId={sop.id} sopTitle={sop.title} />

        <div className="rounded-2xl border border-zinc-800/80 bg-zinc-950/20 p-4">
          <SectionTitle title="Metadata" subtitle="Asset context." />
          <Divider />
          <div className="space-y-2 text-[12px]">
            <div className="flex items-center justify-between">
              <span className="text-zinc-500">Domain</span>
              <span className="text-zinc-200">{sop.domain}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-zinc-500">Client</span>
              <span className="text-zinc-200">{sop.client}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-zinc-500">Owner</span>
              <span className="text-zinc-200">{sop.owner}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-zinc-500">Created</span>
              <span className="text-zinc-200 tabular-nums">{formatDate(sop.createdAt)}</span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-zinc-500">Updated</span>
              <span className="text-zinc-200 tabular-nums">{formatDate(sop.updatedAt)}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

function DeliverableSurface({ sop }: { sop: SOP }) {
  // This is a structured, executive-grade deliverable surface.
  // Not an editor. Not a builder.
  return (
    <div className="rounded-2xl border border-zinc-800/80 bg-zinc-950/20 p-4">
      <div className="flex items-start justify-between gap-3">
        <div>
          <div className="text-[11px] text-zinc-500">Deliverable</div>
          <div className="mt-1 text-[13px] font-medium text-zinc-100 tracking-wide">Production SOP Output (Preview)</div>
          <div className="mt-1 text-[12px] text-zinc-500 leading-5">
            This is a display surface representing the deliverable. Editing/building is intentionally excluded.
          </div>
        </div>
        <Badge tone="neutral">Executive</Badge>
      </div>

      <Divider />

      <div className="grid grid-cols-12 gap-3">
        <div className="col-span-12 md:col-span-8 space-y-3">
          <Box title="Purpose" content="Define the operational intent and outcomes. This section is designed for executives to scan quickly." />
          <Box title="Scope" content="What is included, what is excluded, and where the procedure applies." />
          <Box title="Inputs" content="Systems, credentials, tools, and prerequisite checks required to execute." />
          <Box title="Procedure" content={<ProcedurePreview title={sop.title} />} />
          <Box title="Quality Controls" content="Verification steps, failure conditions, and escalation triggers." />
        </div>
        <div className="col-span-12 md:col-span-4 space-y-3">
          <MiniSpec
            title="Execution Standard"
            items={[
              { k: "Time", v: "< 15 minutes" },
              { k: "Owner", v: sop.owner },
              { k: "State", v: sop.state },
              { k: "Version", v: sop.version },
            ]}
          />
          <MiniSpec
            title="Risk"
            items={[
              { k: "Failure", v: "Operational delay" },
              { k: "Severity", v: sop.domain === "Finance" ? "High" : "Medium" },
              { k: "Escalate", v: "Ops Lead" },
            ]}
          />
          <MiniSpec
            title="Assets"
            items={[
              { k: "Tags", v: sop.tags.join(", ") },
              { k: "Domain", v: sop.domain },
              { k: "Client", v: sop.client },
            ]}
          />
        </div>
      </div>
    </div>
  );
}

function Box({ title, content }: { title: string; content: React.ReactNode }) {
  return (
    <div className="rounded-xl border border-zinc-800/80 bg-zinc-950/25 p-3">
      <div className="text-[12px] font-medium text-zinc-100 tracking-wide">{title}</div>
      <div className="mt-2 text-[12px] text-zinc-400 leading-6">{content}</div>
    </div>
  );
}

function MiniSpec({ title, items }: { title: string; items: Array<{ k: string; v: string }> }) {
  return (
    <div className="rounded-xl border border-zinc-800/80 bg-zinc-950/20 p-3">
      <div className="text-[12px] font-medium text-zinc-100 tracking-wide">{title}</div>
      <div className="mt-3 space-y-2">
        {items.map((it) => (
          <div key={it.k} className="flex items-center justify-between gap-3 text-[12px]">
            <span className="text-zinc-500">{it.k}</span>
            <span className="text-zinc-200 text-right">{it.v}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

function ProcedurePreview({ title }: { title: string }) {
  const steps = [
    "Confirm prerequisites and access rights.",
    "Run the primary workflow against the operational checklist.",
    "Validate outputs using the quality controls.",
    "Record outcome and escalate on failure conditions.",
  ];

  return (
    <div className="space-y-2">
      <div className="rounded-lg border border-zinc-800/80 bg-zinc-950/20 p-2">
        <div className="text-[11px] text-zinc-500">Procedure Name</div>
        <div className="mt-1 text-[12px] text-zinc-200">{title}</div>
      </div>
      <div className="rounded-lg border border-zinc-800/80 bg-zinc-950/20 p-2">
        <div classNam
