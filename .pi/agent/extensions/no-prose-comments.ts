/**
 * no-prose-comments
 *
 * Enforces the global AGENTS.md <never-write-comments> rule: any comment line
 * the agent ADDS to a code file must be tagged `TODO: @PARKER-AGENT`.
 *
 * Blocks `write` / `edit` tool calls that introduce untagged comment lines.
 * Pre-existing comments are untouched (only newly added comment lines count).
 *
 * Escape hatch: set PI_ALLOW_COMMENTS=1 to disable.
 */

import { readFileSync } from "node:fs";
import { isAbsolute, join } from "node:path";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { isToolCallEventType } from "@earendil-works/pi-coding-agent";

const REQUIRED_TAG = /TODO:\s*@PARKER-AGENT/;

type Family = "c" | "hash" | "dash" | "semi" | "lisp" | "html";

const FAMILY_BY_EXT: Record<string, Family> = {
	// c-style
	ts: "c",
	tsx: "c",
	mts: "c",
	cts: "c",
	js: "c",
	jsx: "c",
	mjs: "c",
	cjs: "c",
	go: "c",
	rs: "c",
	java: "c",
	kt: "c",
	kts: "c",
	swift: "c",
	c: "c",
	h: "c",
	cc: "c",
	cpp: "c",
	cxx: "c",
	hpp: "c",
	hh: "c",
	cs: "c",
	scala: "c",
	sc: "c",
	dart: "c",
	php: "c",
	proto: "c",
	zig: "c",
	sol: "c",
	gradle: "c",
	groovy: "c",
	m: "c",
	mm: "c",
	css: "c",
	scss: "c",
	sass: "c",
	less: "c",
	jsonc: "c",
	json5: "c",
	// hash-style
	py: "hash",
	pyi: "hash",
	rb: "hash",
	sh: "hash",
	bash: "hash",
	zsh: "hash",
	fish: "hash",
	pl: "hash",
	pm: "hash",
	r: "hash",
	yaml: "hash",
	yml: "hash",
	toml: "hash",
	tf: "hash",
	tfvars: "hash",
	nix: "hash",
	ex: "hash",
	exs: "hash",
	jl: "hash",
	ps1: "hash",
	psm1: "hash",
	mk: "hash",
	cmake: "hash",
	gradlekts: "hash",
	// dash-style
	lua: "dash",
	sql: "dash",
	hs: "dash",
	elm: "dash",
	ada: "dash",
	moon: "dash",
	// lisp-family
	clj: "lisp",
	cljs: "lisp",
	cljc: "lisp",
	cljd: "lisp",
	cljr: "lisp",
	bb: "lisp",
	edn: "lisp",
	fnl: "lisp",
	el: "lisp",
	lisp: "lisp",
	scm: "lisp",
	rkt: "lisp",
	// semicolon-style
	asm: "semi",
	s: "semi",
	ini: "semi",
	// markup
	html: "html",
	htm: "html",
	xml: "html",
	vue: "html",
	svelte: "html",
	xhtml: "html",
};

const FAMILY_BY_FILENAME: Record<string, Family> = {
	dockerfile: "hash",
	makefile: "hash",
	justfile: "hash",
	rakefile: "hash",
	gemfile: "hash",
	brewfile: "hash",
	procfile: "hash",
};

const COMMENT_PATTERNS: Record<Family, RegExp[]> = {
	c: [/^\/\//, /^\/\*/, /^\*[\s*/]/, /^\*$/],
	hash: [/^#/],
	dash: [/^--/],
	semi: [/^;/],
	lisp: [/^;/, /^#_/, /^\(comment(\s|$|\))/],
	html: [/^<!--/, /^-->/],
};

/** Comment lines that are machine directives / delimiters, not prose. */
const ALLOWED_PATTERNS: RegExp[] = [
	REQUIRED_TAG,
	/^#!/,
	/^(\/\*+|\*+\/?|\/\/+|#+|-{2,}|;+|<!--|-->|"""|''')$/,
	/\b(eslint-disable|eslint-enable|biome-ignore|prettier-ignore|dprint-ignore|stylelint-|oxlint-)/i,
	/@ts-(ignore|expect-error|nocheck)|<reference\s|\/\/\/\s*</,
	/\b(noqa|type:\s*ignore|pyright:|ruff:|mypy:|pylint:|flake8:)/i,
	/\b(shellcheck\s+disable|nolint|golangci|swiftlint:|rustfmt::|clippy::)/,
	/^(go:|\+build)|\bgo:(build|generate|embed)\b/,
	/\b(istanbul|c8|v8|coverage)\s+ignore\b/i,
	/\b(@generated|SPDX-License-Identifier|jscpd:|ast-grep-ignore|pi-lens)/,
	/^#\s*(region|endregion|pragma|include|define|if|ifdef|ifndef|else|elif|endif|import|region)\b/,
	/^#\s*-\*-|^#\s*coding[:=]/,
];

function familyFor(filePath: string): Family | undefined {
	const base = filePath.split("/").pop()?.toLowerCase() ?? "";
	const byName =
		FAMILY_BY_FILENAME[base] ?? FAMILY_BY_FILENAME[base.replace(/\..*$/, "")];
	if (byName) return byName;
	const ext = base.includes(".") ? base.slice(base.lastIndexOf(".") + 1) : "";
	return FAMILY_BY_EXT[ext];
}

function commentLines(text: string, family: Family): string[] {
	const patterns = COMMENT_PATTERNS[family];
	const out: string[] = [];
	for (const raw of text.split("\n")) {
		const line = raw.trim();
		if (line === "") continue;
		if (!patterns.some((p) => p.test(line))) continue;
		out.push(line);
	}
	return out;
}

function isAllowed(line: string): boolean {
	return ALLOWED_PATTERNS.some((p) => p.test(line));
}

/** Comment lines present in `next` beyond what `prev` already had. */
function addedComments(prev: string, next: string, family: Family): string[] {
	const before = new Map<string, number>();
	for (const line of commentLines(prev, family)) {
		before.set(line, (before.get(line) ?? 0) + 1);
	}
	const added: string[] = [];
	for (const line of commentLines(next, family)) {
		const count = before.get(line) ?? 0;
		if (count > 0) {
			before.set(line, count - 1);
			continue;
		}
		if (!isAllowed(line)) added.push(line);
	}
	return added;
}

function readIfExists(absPath: string): string {
	try {
		return readFileSync(absPath, "utf8");
	} catch {
		return "";
	}
}

export default function (pi: ExtensionAPI) {
	pi.on("tool_call", async (event, ctx) => {
		if (process.env.PI_ALLOW_COMMENTS === "1") return undefined;
		if (event.toolName !== "write" && event.toolName !== "edit")
			return undefined;

		const relOrAbs = (event.input as { path?: string }).path;
		if (!relOrAbs) return undefined;
		const family = familyFor(relOrAbs);
		if (!family) return undefined;

		const absPath = isAbsolute(relOrAbs) ? relOrAbs : join(ctx.cwd, relOrAbs);
		const offenders: string[] = [];

		if (isToolCallEventType("write", event)) {
			offenders.push(
				...addedComments(readIfExists(absPath), event.input.content, family),
			);
		} else if (isToolCallEventType("edit", event)) {
			for (const e of event.input.edits ?? []) {
				offenders.push(...addedComments(e.oldText, e.newText, family));
			}
		}

		if (offenders.length === 0) return undefined;

		const sample = offenders
			.slice(0, 5)
			.map((l) => `  ${l}`)
			.join("\n");
		if (ctx.hasUI) {
			ctx.ui.notify(
				`Blocked ${offenders.length} untagged comment(s) in ${relOrAbs}`,
				"warning",
			);
		}
		return {
			block: true,
			reason:
				`Blocked by never-write-comments rule: ${offenders.length} new comment line(s) in ${relOrAbs} ` +
				`are not tagged \`TODO: @PARKER-AGENT\`.\n${sample}\n` +
				`Rewrite each as a tagged one-liner, e.g. \`// TODO: @PARKER-AGENT <short summary>\`, or delete it.`,
		};
	});
}
