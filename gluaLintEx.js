const { readFileSync } = require('fs');
const { normalize } = require('path');
const { spawnSync } = require('child_process');

const res = spawnSync('glualint', ['.']);
if (res.status === null) {
    console.error('Interrupted');
    process.exit(1);
}
if (res.status === 0) {
    process.exit(0);
}

if (res.status === 1) {
    const errRegExp = /^(.+): \[(Warning|Error)\] line (\d+), column (\d+) - line (\d+), column (\d+): (.+)$/;
    const output = res.stdout.toString().split(/\r?\n/).filter(l => !!l).map(l => l.match(errRegExp)).map(m => ({
        file: normalize(m[1]),
        type: m[2].toLowerCase(),
        lineStart: parseInt(m[3], 10),
        columnStart: parseInt(m[4], 10),
        lineEnd: parseInt(m[5], 10),
        columnEnd: parseInt(m[6], 10),
        message: m[7],
    }));
    const fileCache = {};
    for (const o of output) {
        fileCache[o.file] = readFileSync(o.file, 'utf8').split(/\r?\n/);
    }
    const reportErrors = output.filter(o => {
        const file = fileCache[o.file]
        if (file[0].includes('--glualint:ignore-file')) {
            return false;
        }
        if (file[o.lineStart - 2].includes('--glualint:ignore-next-line')) {
            return false;
        }
        return true;
    });
    if (reportErrors.length === 0) {
        process.exit(0);
    }
    for (const r of reportErrors) {
        console.log(`${r.type} ${r.file}:${r.lineStart}:${r.columnStart}-${r.lineEnd}:${r.columnEnd} ${r.message}`);
    }
}