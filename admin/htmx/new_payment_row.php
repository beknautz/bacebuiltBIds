<tr class="payment-row">
  <td>
    <input type="hidden" name="pay_id[]" value="0">
    <input type="text" name="pay_milestone[]" class="form-control"
           placeholder="e.g. Deposit" value="">
  </td>
  <td>
    <input type="number" name="pay_amount[]" class="form-control text-end"
           value="" step="0.01" min="0" placeholder="0.00">
  </td>
  <td>
    <input type="number" name="pay_pct[]" class="form-control text-end"
           value="" step="0.1" min="0" max="100" placeholder="0">
  </td>
  <td>
    <input type="text" name="pay_desc[]" class="form-control"
           placeholder="Due upon contract signing" value="">
  </td>
  <td>
    <button type="button" class="btn btn-outline-danger btn-sm" onclick="removeRow(this)">
      <i class="bi bi-x"></i>
    </button>
  </td>
</tr>
