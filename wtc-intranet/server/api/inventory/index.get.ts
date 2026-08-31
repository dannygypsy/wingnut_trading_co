import prisma from '../../utils/prisma'
import { Prisma } from '@prisma/client'

export default defineEventHandler(async (event) => {
    const query = getQuery(event)
    const category = query.category as string | undefined
    const lowStock = query.lowStock === 'true'

    // Summary — always unfiltered
    const summaryRaw = await prisma.$queryRaw<any[]>`
    SELECT
      COUNT(*) as total_items,
      SUM(remaining) as total_quantity,
      SUM(cost * remaining) as total_cost_value,
      SUM(retail * remaining) as total_retail_value,
      SUM((retail - cost) * remaining) as potential_profit
    FROM wtc_inventory
  `
    const s = summaryRaw[0]
    const summary = {
        totalItems: Number(s.total_items) || 0,
        totalQuantity: Number(s.total_quantity) || 0,
        totalCostValue: parseFloat(s.total_cost_value) || 0,
        totalRetailValue: parseFloat(s.total_retail_value) || 0,
        potentialProfit: parseFloat(s.potential_profit) || 0,
    }

    // Low stock items — aggregated by product_id + size
    const lowStockItems = await prisma.$queryRaw<any[]>`
    SELECT
      MIN(name) as name,
      size,
      MIN(category) as category,
      SUM(num_purchased) as num_purchased,
      SUM(remaining) as remaining,
      ROUND((SUM(remaining) / SUM(num_purchased)) * 100, 1) as stock_percentage
    FROM wtc_inventory
    GROUP BY product_id, size
    HAVING SUM(remaining) < (SUM(num_purchased) * 0.25)
    ORDER BY stock_percentage ASC
  `

    // Inventory list with optional filters
    const categoryFilter = category ? Prisma.sql`AND category = ${category}` : Prisma.empty
    const lowStockFilter = lowStock ? Prisma.sql`AND remaining < (num_purchased * 0.25)` : Prisma.empty

    const items = await prisma.$queryRaw<any[]>`
    SELECT
      id, product_id, category, name, size, full_name, type,
      cost, retail, purchased_on, num_purchased, remaining,
      (retail - cost) as profit_margin,
      (cost * remaining) as total_cost,
      (retail * remaining) as total_retail,
      ROUND((remaining / num_purchased) * 100, 1) as stock_percentage
    FROM wtc_inventory
    WHERE 1=1
    ${categoryFilter}
    ${lowStockFilter}
    ORDER BY category, name, size
  `

    const inventory = items.map(item => ({
        ...item,
        cost: parseFloat(item.cost) || 0,
        retail: parseFloat(item.retail) || 0,
        profit_margin: parseFloat(item.profit_margin) || 0,
        total_cost: parseFloat(item.total_cost) || 0,
        total_retail: parseFloat(item.total_retail) || 0,
        stock_percentage: parseFloat(item.stock_percentage) || 0,
        num_purchased: Number(item.num_purchased) || 0,
        remaining: Number(item.remaining) || 0,
    }))

    return { summary, inventory, lowStockItems }
})