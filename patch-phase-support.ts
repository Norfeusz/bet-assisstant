/**
 * Patch existing code to add phase support in remaining locations
 * This will be run as a one-time fix
 */

import * as fs from 'fs'
import * as path from 'path'

const filePath = path.join(process.cwd(), 'server', 'routes', 'strefa-typera.ts')
let content = fs.readFileSync(filePath, 'utf-8')

// Find and replace pattern 1: coupons create (line ~1517)
const pattern1 = /(\s+potential_win: row\[34\] \? parseFloat\(row\[34\]\) : null,\s+)/g
const replacement1 = '$1phase: row[44] || \'C\',\n\t\t\t\t\t'

// Find and replace pattern 2: bets create in migrate (line ~1656)
const pattern2 = /(flashscore_link: row\[32\] \|\| null,\s+}\s+}\)\s+betsInserted\+\+)/g
const replacement2 = 'flashscore_link: row[32] || null,\n\t\t\t\t\tphase: row[44] || \'C\',\n\t\t\t\t}\n\t\t\t})\n\t\t\tbetsInserted++'

// Find and replace pattern 3: coupons create in migrate (line ~1719)
const pattern3 = /(potential_win: row\[34\] \? parseFloat\(row\[34\]\) : null,\s+}\s+}\)\s+couponsInserted\+\+)/g
const replacement3 = 'potential_win: row[34] ? parseFloat(row[34]) : null,\n\t\t\t\t\tphase: row[44] || \'C\',\n\t\t\t\t}\n\t\t\t})\n\t\t\tcouponsInserted++'

let changes = 0

if (content.match(pattern1)) {
	content = content.replace(pattern1, replacement1)
	changes++
	console.log('✅ Added phase to coupons create (create coupon)')
}

if (content.match(pattern2)) {
	content = content.replace(pattern2, replacement2)
	changes++
	console.log('✅ Added phase to bets migrate')
}

if (content.match(pattern3)) {
	content = content.replace(pattern3, replacement3)
	changes++
	console.log('✅ Added phase to coupons migrate')
}

if (changes > 0) {
	fs.writeFileSync(filePath, content, 'utf-8')
	console.log(`\n📝 Successfully updated ${changes} locations in strefa-typera.ts`)
} else {
	console.log('ℹ️  No changes needed - all phase fields already present')
}
