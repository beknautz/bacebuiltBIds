<tr class="item-row">
  <td>
    <input type="hidden" name="item_id" value="0">
    <input type="text" name="item_category" class="form-control" placeholder="Labor" value="">
  </td>
  <td>
    <input type="text" name="item_description" class="form-control" placeholder="Description of work or material" value="">
  </td>
  <td>
    <input type="number" name="item_qty" class="form-control text-end item-qty"
           value="1" step="0.001" min="0" oninput="calcTotals()">
  </td>
  <td>
    <input type="text" name="item_unit" class="form-control" value="EA">
  </td>
  <td>
    <input type="number" name="item_unit_price" class="form-control text-end item-price"
           value="" step="0.01" min="0" oninput="calcTotals()" placeholder="0.00">
  </td>
  <td class="text-end item-line-total align-middle">$0.00</td>
  <td>
    <button type="button" class="btn btn-outline-danger btn-sm"
            onclick="removeRow(this); calcTotals();">
      <i class="bi bi-x"></i>
    </button>
  </td>
</tr>
